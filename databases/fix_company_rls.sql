-- Enable RLS on companies table
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;

-- Allow read access to everyone (public company profiles)
DROP POLICY IF EXISTS "Public companies are viewable by everyone" ON public.companies;
CREATE POLICY "Public companies are viewable by everyone" 
ON public.companies FOR SELECT 
USING ( true );

-- Enable RLS on company_members table (CRITICAL for the next policy to work if it queries this table)
ALTER TABLE public.company_members ENABLE ROW LEVEL SECURITY;

-- Allow users to see their own membership (Needed to verify role)
DROP POLICY IF EXISTS "Users can view their own membership" ON public.company_members;
CREATE POLICY "Users can view their own membership"
ON public.company_members FOR SELECT
USING ( user_id = auth.uid() );

-- Allow update access to owners and managers via company_members check
DROP POLICY IF EXISTS "Owners and Managers can update their company" ON public.companies;
CREATE POLICY "Owners and Managers can update their company" 
ON public.companies FOR UPDATE 
USING (
  auth.uid() IN (
    SELECT user_id 
    FROM public.company_members 
    WHERE company_id = id 
    AND role::text IN ('owner', 'manager')
  )
);

-- Allow insert (anyone can register a new company)
DROP POLICY IF EXISTS "Users can register new companies" ON public.companies;
CREATE POLICY "Users can register new companies" 
ON public.companies FOR INSERT 
WITH CHECK ( true );
