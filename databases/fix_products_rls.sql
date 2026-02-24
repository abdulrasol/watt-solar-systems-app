-- Enable RLS on products if not already enabled
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Policy: Public/Authenticated Read Access
-- Everyone can see active products? Or just authenticated?
-- Adjust as needed. For now, public read for the marketplace.
DROP POLICY IF EXISTS "Public read products" ON public.products;
CREATE POLICY "Public read products" ON public.products
FOR SELECT
USING (status = 'active'::product_status OR 
  EXISTS (
    SELECT 1 FROM public.company_members
    WHERE user_id = auth.uid() AND company_id = products.company_id
  )
);

-- Policy: Company Members can INSERT, UPDATE, DELETE their own products
DROP POLICY IF EXISTS "Companies manage products" ON public.products;
CREATE POLICY "Companies manage products" ON public.products
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.company_members 
    WHERE user_id = auth.uid() 
    AND company_id = products.company_id
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.company_members 
    WHERE user_id = auth.uid() 
    AND company_id = products.company_id
  )
);
