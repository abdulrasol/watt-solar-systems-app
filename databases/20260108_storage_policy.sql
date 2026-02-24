-- Create storage bucket for company logos if not exists
INSERT INTO storage.buckets (id, name, public)
VALUES ('company_logos', 'company_logos', true)
ON CONFLICT (id) DO NOTHING;

-- Policy: Allow authenticated users to upload their own files (or any file for now to unblock)
-- Note: 'storage.objects' RLS
CREATE POLICY "Allow authenticated uploads"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'company_logos');

-- Policy: Allow public to view files
CREATE POLICY "Allow public viewing"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'company_logos');

-- Policy: Allow users to update their own files (optional)
CREATE POLICY "Allow authenticated updates"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'company_logos');

-- Companies Table Policies (Ensure RLS is enabled and allows insert)
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated users to create companies"
ON public.companies FOR INSERT
TO authenticated
WITH CHECK (true);

-- Allow users to view key company details (public)
CREATE POLICY "Allow public read access"
ON public.companies FOR SELECT
TO public
USING (true);


-- Allow owner/admin update (This might need precise logic based on company_members, but for now simple check)
-- Complex policy usually involves exists check on company_members.

-- Company Members Policy
ALTER TABLE public.company_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow users to join companies (self-insert)"
ON public.company_members FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Allow members to view their memberships"
ON public.company_members FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

