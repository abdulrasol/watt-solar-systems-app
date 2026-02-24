-- Policy to allow reading profiles
-- Often profiles need to be visible to other authenticated users (e.g. searching for members, viewing team)

-- Enable RLS just in case (usually already enabled)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create policy if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_policies
        WHERE schemaname = 'public'
        AND tablename = 'profiles'
        AND policyname = 'Public profiles are viewable by everyone'
    ) THEN
        CREATE POLICY "Public profiles are viewable by everyone"
        ON public.profiles
        FOR SELECT
        USING (true); -- Or stricter: auth.role() = 'authenticated'
    END IF;
END
$$;
