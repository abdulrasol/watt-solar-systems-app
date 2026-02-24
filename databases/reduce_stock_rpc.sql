-- Secure Function to Reduce Product Stock
-- This ensures atomic reduction and avoids race conditions or dependency on local app state.

CREATE OR REPLACE FUNCTION reduce_stock_secure(
  p_product_id uuid,
  p_quantity_sold integer
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER -- Run as database owner
AS $$
BEGIN
  UPDATE products
  SET 
    stock_quantity = stock_quantity - p_quantity_sold,
    updated_at = now()
  WHERE id = p_product_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Product with ID % not found', p_product_id;
  END IF;
END;
$$;
