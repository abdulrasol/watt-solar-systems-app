-- 1. Update User Role Enum to include 'inventory_manager' (if not exists)
ALTER TYPE public.user_role ADD VALUE IF NOT EXISTS 'inventory_manager';

-- 2. Create RPC to insert product with all headers (Transaction)
CREATE OR REPLACE FUNCTION public.create_product_full(
  product_data JSONB,
  pricing_tiers JSONB,
  options JSONB,
  category_ids JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  new_product_id UUID;
  tier_item JSONB;
  option_item JSONB;
  val_item JSONB;
  cat_id TEXT;
BEGIN
  -- A. Insert Product
  INSERT INTO public.products (
    company_id,
    name,
    sku,
    category,
    description,
    image_url,
    cost_price,
    retail_price,
    wholesale_price,
    stock_quantity,
    min_stock_alert,
    specs,
    status,
    discount
  ) VALUES (
    (product_data->>'company_id')::UUID,
    product_data->>'name',
    product_data->>'sku',
    product_data->>'category',
    product_data->>'description',
    product_data->>'image_url',
    COALESCE((product_data->>'cost_price')::NUMERIC, 0),
    COALESCE((product_data->>'retail_price')::NUMERIC, 0),
    COALESCE((product_data->>'wholesale_price')::NUMERIC, 0),
    COALESCE((product_data->>'stock_quantity')::INT, 0),
    COALESCE((product_data->>'min_stock_alert')::INT, 5),
    COALESCE(product_data->'specs', '{}'::JSONB),
    COALESCE((product_data->>'status')::product_status, 'active'),
    COALESCE((product_data->>'discount')::NUMERIC, 0)
  ) RETURNING id INTO new_product_id;

  -- B. Insert Pricing Tiers
  IF pricing_tiers IS NOT NULL AND jsonb_array_length(pricing_tiers) > 0 THEN
    FOR tier_item IN SELECT * FROM jsonb_array_elements(pricing_tiers)
    LOOP
      INSERT INTO public.product_pricing_tiers (product_id, min_quantity, unit_price)
      VALUES (
        new_product_id,
        (tier_item->>'min_quantity')::INT,
        (tier_item->>'unit_price')::NUMERIC
      );
    END LOOP;
  END IF;

  -- C. Insert Options & Values
  IF options IS NOT NULL AND jsonb_array_length(options) > 0 THEN
    FOR option_item IN SELECT * FROM jsonb_array_elements(options)
    LOOP
      DECLARE
        new_option_id UUID;
      BEGIN
        INSERT INTO public.product_options (product_id, name, is_required)
        VALUES (
          new_product_id,
          option_item->>'name',
          COALESCE((option_item->>'is_required')::BOOLEAN, false)
        ) RETURNING id INTO new_option_id;

        -- Insert Values for this Option
        IF option_item->'values' IS NOT NULL THEN
            FOR val_item IN SELECT * FROM jsonb_array_elements(option_item->'values')
            LOOP
                INSERT INTO public.product_option_values (option_id, value, extra_cost)
                VALUES (
                    new_option_id,
                    val_item->>'value',
                    COALESCE((val_item->>'extra_cost')::NUMERIC, 0)
                );
            END LOOP;
        END IF;
      END;
    END LOOP;
  END IF;

  -- D. Insert Company Category Links
  IF category_ids IS NOT NULL AND jsonb_array_length(category_ids) > 0 THEN
    FOR cat_id IN SELECT * FROM jsonb_array_elements_text(category_ids)
    LOOP
      INSERT INTO public.product_company_categories (product_id, category_id)
      VALUES (new_product_id, cat_id::UUID);
    END LOOP;
  END IF;

  RETURN json_build_object('id', new_product_id, 'success', true);
EXCEPTION WHEN OTHERS THEN
  RAISE;
END;
$$;

-- 3. Create RPC to UPDATE product with all headers (Transaction)
CREATE OR REPLACE FUNCTION public.update_product_full(
  p_product_id UUID,
  p_product_data JSONB,
  p_pricing_tiers JSONB,
  p_options JSONB,
  p_category_ids JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  tier_item JSONB;
  option_item JSONB;
  val_item JSONB;
  cat_id TEXT;
BEGIN
  -- A. Update Product
  UPDATE public.products SET
    name = p_product_data->>'name',
    sku = p_product_data->>'sku',
    category = p_product_data->>'category',
    description = p_product_data->>'description',
    image_url = p_product_data->>'image_url',
    cost_price = COALESCE((p_product_data->>'cost_price')::NUMERIC, 0),
    retail_price = COALESCE((p_product_data->>'retail_price')::NUMERIC, 0),
    wholesale_price = COALESCE((p_product_data->>'wholesale_price')::NUMERIC, 0),
    stock_quantity = COALESCE((p_product_data->>'stock_quantity')::INT, 0),
    min_stock_alert = COALESCE((p_product_data->>'min_stock_alert')::INT, 5),
    specs = COALESCE(p_product_data->'specs', '{}'::JSONB),
    status = COALESCE((p_product_data->>'status')::product_status, 'active'),
    discount = COALESCE((p_product_data->>'discount')::NUMERIC, 0)
  WHERE id = p_product_id;

  -- B. Update Pricing Tiers (Replace Strategy)
  DELETE FROM public.product_pricing_tiers WHERE product_id = p_product_id;
  IF p_pricing_tiers IS NOT NULL AND jsonb_array_length(p_pricing_tiers) > 0 THEN
    FOR tier_item IN SELECT * FROM jsonb_array_elements(p_pricing_tiers)
    LOOP
      INSERT INTO public.product_pricing_tiers (product_id, min_quantity, unit_price)
      VALUES (
        p_product_id,
        (tier_item->>'min_quantity')::INT,
        (tier_item->>'unit_price')::NUMERIC
      );
    END LOOP;
  END IF;

  -- C. Update Options & Values (Replace Strategy)
  DELETE FROM public.product_options WHERE product_id = p_product_id; -- Cascade deletes values
  IF p_options IS NOT NULL AND jsonb_array_length(p_options) > 0 THEN
    FOR option_item IN SELECT * FROM jsonb_array_elements(p_options)
    LOOP
      DECLARE
        new_option_id UUID;
      BEGIN
        INSERT INTO public.product_options (product_id, name, is_required)
        VALUES (
          p_product_id,
          option_item->>'name',
          COALESCE((option_item->>'is_required')::BOOLEAN, false)
        ) RETURNING id INTO new_option_id;

        IF option_item->'values' IS NOT NULL THEN
            FOR val_item IN SELECT * FROM jsonb_array_elements(option_item->'values')
            LOOP
                INSERT INTO public.product_option_values (option_id, value, extra_cost)
                VALUES (
                    new_option_id,
                    val_item->>'value',
                    COALESCE((val_item->>'extra_cost')::NUMERIC, 0)
                );
            END LOOP;
        END IF;
      END;
    END LOOP;
  END IF;

  -- D. Update Company Category Links (Replace Strategy)
  DELETE FROM public.product_company_categories WHERE product_id = p_product_id;
  IF p_category_ids IS NOT NULL AND jsonb_array_length(p_category_ids) > 0 THEN
    FOR cat_id IN SELECT * FROM jsonb_array_elements_text(p_category_ids)
    LOOP
      INSERT INTO public.product_company_categories (product_id, category_id)
      VALUES (p_product_id, cat_id::UUID);
    END LOOP;
  END IF;

  RETURN json_build_object('id', p_product_id, 'success', true);
EXCEPTION WHEN OTHERS THEN
  RAISE;
END;
$$;
