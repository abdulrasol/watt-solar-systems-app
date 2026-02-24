-- Secure Function to Ensure B2B Customer Exists
-- This function is called when a B2B order is placed.
-- It ensures the Buyer Company is registered as a Customer in the Seller's CRM.

CREATE OR REPLACE FUNCTION ensure_b2b_customer(
  p_seller_company_id uuid,
  p_buyer_company_id uuid
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER -- Run as database owner to bypass RLS
AS $$
DECLARE
  v_customer_id uuid;
  v_buyer_record RECORD;
BEGIN
  -- 1. Check if relation exists
  SELECT id INTO v_customer_id
  FROM customers
  WHERE company_id = p_seller_company_id
    AND buyer_company_id = p_buyer_company_id
  LIMIT 1;
  
  IF v_customer_id IS NOT NULL THEN
    RETURN v_customer_id;
  END IF;
  
  -- 2. Get buyer info
  SELECT name, address, contact_phone INTO v_buyer_record
  FROM companies 
  WHERE id = p_buyer_company_id;
  
  -- 3. Insert new customer for the seller
  INSERT INTO customers (
    company_id, 
    buyer_company_id, 
    full_name, 
    address,
    phone_number
  )
  VALUES (
    p_seller_company_id, 
    p_buyer_company_id, 
    COALESCE(v_buyer_record.name, 'Unknown Company'), 
    COALESCE(v_buyer_record.address, ''),
    COALESCE(v_buyer_record.contact_phone, '')
  )
  RETURNING id INTO v_customer_id;
  
  RETURN v_customer_id;
END;
$$;
