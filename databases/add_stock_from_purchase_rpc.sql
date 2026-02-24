-- Secure Function to Add Stock from a Purchase (Bypasses RLS)
-- This function is called when a B2B order is completed.
-- It adds items to the Buyer's inventory.

CREATE OR REPLACE FUNCTION add_stock_from_purchase(
  p_company_id uuid,          -- The buyer company ID
  p_product_name text,        -- The product name
  p_quantity int,             -- Quantity to add
  p_unit_cost numeric         -- Unit cost (purchase price)
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER -- Run as database owner to bypass RLS
AS $$
DECLARE
  v_product_id uuid;
  v_current_qty int;
  v_current_cost numeric;
  v_new_cost numeric;
  v_new_total_qty int;
BEGIN
  -- 1. Check if product exists in the buyer's inventory (by name case-insensitive and trimmed)
  SELECT id, stock_quantity, cost_price
  INTO v_product_id, v_current_qty, v_current_cost
  FROM products
  WHERE company_id = p_company_id
    AND TRIM(name) ILIKE TRIM(p_product_name)
  LIMIT 1;

  IF v_product_id IS NOT NULL THEN
    -- 2. Update existing product (Weighted Average Cost)
    -- Formula: ((OldQty * OldCost) + (NewQty * NewCost)) / (OldQty + NewQty)
    
    v_new_total_qty := v_current_qty + p_quantity;
    
    IF v_new_total_qty > 0 THEN
      v_new_cost := ((v_current_qty * v_current_cost) + (p_quantity * p_unit_cost)) / v_new_total_qty;
    ELSE
      v_new_cost := p_unit_cost;
    END IF;

    UPDATE products
    SET 
      stock_quantity = v_new_total_qty,
      cost_price = ROUND(v_new_cost, 2),
      updated_at = NOW()
    WHERE id = v_product_id;

  ELSE
    -- 3. Create new product
    -- We set retail price to cost * 1.25 (25% margin) as default
    INSERT INTO products (
      company_id,
      name,
      description,
      stock_quantity,
      cost_price,
      retail_price,
      status
    ) VALUES (
      p_company_id,
      TRIM(p_product_name), -- Store trimmed name
      'Imported from B2B Purchase',
      p_quantity,
      p_unit_cost,
      ROUND(p_unit_cost * 1.25, 2),
      'active'
    );
  END IF;
END;
$$;
