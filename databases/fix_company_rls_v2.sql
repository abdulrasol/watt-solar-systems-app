-- Create a secure function to check permissions
-- This runs with admin privileges (SECURITY DEFINER), bypassing RLS on the company_members table
CREATE OR REPLACE FUNCTION public.is_company_admin(company_uuid uuid)
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.company_members
    WHERE company_id = company_uuid
    AND user_id = auth.uid()
    AND (role::text = 'owner' OR role::text = 'manager')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update the companies policy to use this function
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Owners and Managers can update their company" ON public.companies;
CREATE POLICY "Owners and Managers can update their company" 
ON public.companies FOR UPDATE 
USING ( public.is_company_admin(id) );

-- Ensure public view is still there
DROP POLICY IF EXISTS "Public companies are viewable by everyone" ON public.companies;
CREATE POLICY "Public companies are viewable by everyone" 
ON public.companies FOR SELECT 
USING ( true );
