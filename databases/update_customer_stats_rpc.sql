-- Secure Function to Update Customer Stats
-- Bypasses RLS to allow buyers to update their corresponding customer record in the seller's CRM
-- OR to allow general stats updates without complex RLS policies for common operations.

CREATE OR REPLACE FUNCTION update_customer_stats_secure(
  p_customer_id uuid,
  p_sale_amount numeric,
  p_paid_amount numeric
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER -- Run as database owner
AS $$
DECLARE
  v_remaining numeric;
BEGIN
  v_remaining := p_sale_amount - p_paid_amount;

  UPDATE customers
  SET 
    balance = balance + v_remaining,
    total_sales = total_sales + p_sale_amount,
    total_paid = total_paid + p_paid_amount,
    updated_at = now()
  WHERE id = p_customer_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Customer with ID % not found', p_customer_id;
  END IF;
END;
$$;
