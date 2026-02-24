-- Finalize RLS for Orders to fix update permission issues
-- This script replaces fragmented policies with a single unified policy for company members.

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- Drop all known disparate policies to avoid 'AND' conflicts (Restrictive vs Permissive) or clutter
DROP POLICY IF EXISTS "Enable insert for company members" ON public.orders;
DROP POLICY IF EXISTS "Enable read for company members" ON public.orders;
DROP POLICY IF EXISTS "Enable all for company members" ON public.orders;
DROP POLICY IF EXISTS "Company members can update their orders" ON public.orders;
DROP POLICY IF EXISTS "Authenticated users can update orders" ON public.orders;
DROP POLICY IF EXISTS "Companies manage their orders" ON public.orders;

-- Create Unified Policy
-- Allows INSERT, SELECT, UPDATE, DELETE if the user belongs to the seller_company_id
CREATE POLICY "Companies manage their orders"
ON public.orders
FOR ALL
TO authenticated
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
