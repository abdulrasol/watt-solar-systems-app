-- Enable RLS
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to insert orders (as buyers)
CREATE POLICY "Allow authenticated users to create orders"
ON public.orders FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = buyer_user_id);

-- Allow buyers to view their own orders
CREATE POLICY "Allow buyers to view their orders"
ON public.orders FOR SELECT
TO authenticated
USING (auth.uid() = buyer_user_id);

-- Allow sellers (company members) to view orders for their company
CREATE POLICY "Allow company members to view their sales"
ON public.orders FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.company_members cm
    WHERE cm.user_id = auth.uid()
    AND cm.company_id = orders.seller_company_id
  )
);

-- Allow order items to be inserted if the parent order exists and belongs to the user
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow users to insert order items"
ON public.order_items FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.orders
    WHERE orders.id = order_items.order_id
    AND orders.buyer_user_id = auth.uid()
  )
);

-- Allow viewing order items
CREATE POLICY "Allow reading order items"
ON public.order_items FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.orders
    WHERE orders.id = order_items.order_id
    AND (
      orders.buyer_user_id = auth.uid() OR
      EXISTS (
        SELECT 1 FROM public.company_members cm
        WHERE cm.user_id = auth.uid()
        AND cm.company_id = orders.seller_company_id
      )
    )
  )
);
