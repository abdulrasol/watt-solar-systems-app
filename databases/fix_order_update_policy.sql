-- Fix for order updates not working
-- The issue is that RLS policies may be blocking updates to the orders table

-- First, check if RLS is enabled (you can run this to see current policies)
-- SELECT * FROM pg_policies WHERE tablename = 'orders';

-- Drop existing policy if it exists, then create new one
DROP POLICY IF EXISTS "Company members can update their orders" ON public.orders;

-- Add UPDATE policy for orders table
-- This allows company members to update orders for their company
CREATE POLICY "Company members can update their orders"
ON public.orders
FOR UPDATE
USING (
  seller_company_id IN (
    SELECT company_id 
    FROM public.company_members 
    WHERE user_id = auth.uid()
  )
)
WITH CHECK (
  seller_company_id IN (
    SELECT company_id 
    FROM public.company_members 
    WHERE user_id = auth.uid()
  )
);

-- Alternative: If you want to allow all authenticated users to update orders (less secure)
-- DROP POLICY IF EXISTS "Authenticated users can update orders" ON public.orders;
-- CREATE POLICY "Authenticated users can update orders"
-- ON public.orders
-- FOR UPDATE
-- USING (auth.role() = 'authenticated')
-- WITH CHECK (auth.role() = 'authenticated');
