-- COMPREHENSIVE FIX for Data Relationships and Security

-- 1. Fix company_members foreign key
ALTER TABLE public.company_members 
DROP CONSTRAINT IF EXISTS company_members_user_id_fkey;

ALTER TABLE public.company_members
ADD CONSTRAINT company_members_user_id_fkey
FOREIGN KEY (user_id)
REFERENCES public.profiles(id);


-- 2. Security Policies (RLS) for Offer Requests
ALTER TABLE public.offer_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own requests" ON public.offer_requests;
CREATE POLICY "Users can view own requests" ON public.offer_requests
FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Public view open requests" ON public.offer_requests;
CREATE POLICY "Public view open requests" ON public.offer_requests
FOR SELECT
USING (status = 'open'::request_status OR auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create requests" ON public.offer_requests;
CREATE POLICY "Users can create requests" ON public.offer_requests
FOR INSERT
WITH CHECK (auth.uid() = user_id);


-- 3. Security Policies (RLS) for Offers
ALTER TABLE public.offers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users see received offers" ON public.offers;
CREATE POLICY "Users see received offers" ON public.offers
FOR SELECT
USING (
  request_id IN (
    SELECT id FROM public.offer_requests WHERE user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Authenticated read offers" ON public.offers;
CREATE POLICY "Authenticated read offers" ON public.offers
FOR SELECT
USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Companies create offers" ON public.offers;
CREATE POLICY "Companies create offers" ON public.offers
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.company_members 
    WHERE user_id = auth.uid() 
    AND company_id = offers.company_id
  )
);
