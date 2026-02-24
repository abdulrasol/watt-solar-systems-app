-- 1. Ensure columns exist
ALTER TABLE public.orders 
ADD COLUMN IF NOT EXISTS payment_method text DEFAULT 'cash';

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'customer_id') THEN
        ALTER TABLE public.orders ADD COLUMN customer_id uuid REFERENCES public.customers(id);
    END IF;
END
$$;

-- 2. RESET RLS Policies for Orders to ensure clean slate
DROP POLICY IF EXISTS "Enable insert for company members" ON public.orders;
DROP POLICY IF EXISTS "Enable read for company members" ON public.orders;
DROP POLICY IF EXISTS "Enable all for company members" ON public.orders;

-- 3. Create Comprehensive Insert Policy
-- Allows insert if you are a Member of the seller company (covers owners too if they are members)
CREATE POLICY "Enable insert for company members" ON public.orders
FOR INSERT TO authenticated
WITH CHECK (
  seller_company_id IN (
    SELECT company_id FROM public.company_members WHERE user_id = auth.uid()
  )
);

-- 4. Create Read/Select Policy
CREATE POLICY "Enable read for company members" ON public.orders
FOR SELECT TO authenticated
USING (
  seller_company_id IN (
    SELECT company_id FROM public.company_members WHERE user_id = auth.uid()
  )
);

-- 5. Ensure Customers Table RLS is also set
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable all for company members" ON public.customers;
DROP POLICY IF EXISTS "Enable all for owners and members local" ON public.customers;

CREATE POLICY "Enable all for company members" ON public.customers
AS PERMISSIVE FOR ALL
TO authenticated
USING (
  company_id IN (
      SELECT company_id FROM public.company_members WHERE user_id = auth.uid()
  )
);
