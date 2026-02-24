-- Enable RLS on core company tables
ALTER TABLE public.company_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;

-- Policy 1: Users can view their own membership rows
-- This is critical to find which company you belong to.
CREATE POLICY "Users can view own membership" ON public.company_members
FOR SELECT
USING (auth.uid() = user_id);

-- Policy 2: Public read access to companies
-- Or restrict to members only if prefered.
-- For now, allow all authenticated users to see company details.
CREATE POLICY "Public company read" ON public.companies
FOR SELECT
USING (true);

-- Policy 3: Company members can view other members of the same company (optional but useful)
CREATE POLICY "View team members" ON public.company_members
FOR SELECT
USING (
  company_id IN (
    SELECT company_id FROM public.company_members WHERE user_id = auth.uid()
  )
);
