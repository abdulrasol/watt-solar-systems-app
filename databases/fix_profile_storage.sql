-- 1. Create 'profiles' bucket for user avatars
INSERT INTO storage.buckets (id, name, public)
VALUES ('profiles', 'profiles', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Reset Policies for 'profiles' bucket
DROP POLICY IF EXISTS "Public Profile Access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Profile Upload" ON storage.objects;
DROP POLICY IF EXISTS "Owner Profile Update" ON storage.objects;

-- 3. Create Policies

-- Allow public read access to avatars
CREATE POLICY "Public Profile Access"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'profiles');

-- Allow authenticated users to upload avatars
CREATE POLICY "Authenticated Profile Upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'profiles');

-- Allow users to update/delete their own avatars
CREATE POLICY "Owner Profile Update"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'profiles' AND auth.uid() = owner);

CREATE POLICY "Owner Profile Delete"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'profiles' AND auth.uid() = owner);
