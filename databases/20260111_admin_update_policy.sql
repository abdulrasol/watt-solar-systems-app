-- Policy: Allow admins to update any company
CREATE POLICY "Allow admins to update companies"
ON public.companies FOR UPDATE
TO authenticated
USING (
  (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'::user_type
);

-- Policy: Allow admins to update company members (e.g. to change roles or remove members)
CREATE POLICY "Allow admins to update company members"
ON public.company_members FOR UPDATE
TO authenticated
USING (
  (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'::user_type
);

-- Policy: Allow admins to delete company members
CREATE POLICY "Allow admins to delete company members"
ON public.company_members FOR DELETE
TO authenticated
USING (
  (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'::user_type
);

-- Policy: Allow admins to view all company members (override member check)
CREATE POLICY "Allow admins to view all company members"
ON public.company_members FOR SELECT
TO authenticated
USING (
  (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'::user_type
);
