-- 1. Create a security definer function to check if the current user is an admin or owner of a company
-- This avoids recursion in policies
CREATE OR REPLACE FUNCTION is_company_admin(company_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM company_members 
    WHERE company_id = company_uuid 
      AND user_id = auth.uid() 
      AND (role IN ('owner', 'manager') OR roles && ARRAY['owner', 'manager'])
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Enable RLS on company_members if not already enabled
ALTER TABLE public.company_members ENABLE ROW LEVEL SECURITY;

-- 3. Drop existing restrictive policies
DROP POLICY IF EXISTS "Users can view own membership" ON public.company_members;
DROP POLICY IF EXISTS "View team members" ON public.company_members;
DROP POLICY IF EXISTS "Admins can manage members" ON public.company_members;

-- 4. Create new comprehensive policies

-- Allow users to see their own membership OR admins to see all members in their company
CREATE POLICY "Select members" ON public.company_members
FOR SELECT
USING (
  auth.uid() = user_id 
  OR is_company_admin(company_id)
);

-- Allow company admins (owner/manager) to add new members
CREATE POLICY "Insert members" ON public.company_members
FOR INSERT
WITH CHECK (
  is_company_admin(company_id)
);

-- Allow company admins to update member roles/permissions
CREATE POLICY "Update members" ON public.company_members
FOR UPDATE
USING (
  is_company_admin(company_id)
);

-- Allow company admins to remove members
CREATE POLICY "Delete members" ON public.company_members
FOR DELETE
USING (
  is_company_admin(company_id)
);
