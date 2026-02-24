-- Allow users to see items for orders they are part of (buyer or seller)
-- Simple policy: if you can see the order, you can see its items.

-- First, ensure order_items is queryable
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own order items" ON public.order_items;

CREATE POLICY "Users can view their own order items"
ON public.order_items
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.orders
    WHERE orders.id = order_items.order_id
    AND (
      orders.buyer_user_id = auth.uid() OR 
      orders.seller_company_id IN ( -- Check if user belongs to seller company
        SELECT company_id FROM public.company_members WHERE user_id = auth.uid()
      )
    )
  )
);

-- Allow insert
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.order_items;
CREATE POLICY "Enable insert for authenticated users"
ON public.order_items
FOR INSERT
TO authenticated
WITH CHECK (true);
