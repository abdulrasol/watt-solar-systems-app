-- 1. Reset Policies for 'products' bucket
-- We drop to ensure clean slate, then re-create.

DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow public viewing" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to update own files" ON storage.objects;
-- Drop any other potentially conflicting policies based on your screenshot
DROP POLICY IF EXISTS "full 1ifhysk_0" ON storage.objects;
DROP POLICY IF EXISTS "full 1ifhysk_1" ON storage.objects;
DROP POLICY IF EXISTS "full 1ifhysk_2" ON storage.objects;
DROP POLICY IF EXISTS "full 1ifhysk_3" ON storage.objects;
DROP POLICY IF EXISTS "read 1ifhysk_0" ON storage.objects;

-- 2. Create Simple, Permissive Policies for 'products'

-- ALLOW UPLOAD: Any authenticated user can upload to 'products'
CREATE POLICY "Enable Insert for Authenticated Users"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'products');

-- ALLOW VIEW: Everyone (public) can view 'products'
CREATE POLICY "Enable Read for Public"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'products');

-- ALLOW UPDATE/DELETE: Users can manage their own files
CREATE POLICY "Enable Update for Owners"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'products' AND auth.uid() = owner);

CREATE POLICY "Enable Delete for Owners"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'products' AND auth.uid() = owner);
