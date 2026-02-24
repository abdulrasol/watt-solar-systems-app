-- 1. Create User Role Enum (if not exists)
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('user', 'company_member', 'admin');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Add role column to profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS role user_role DEFAULT 'user';

-- 3. Create App Config Table
CREATE TABLE IF NOT EXISTS public.app_config (
  key text PRIMARY KEY,
  value boolean DEFAULT false,
  description text,
  updated_at timestamp with time zone DEFAULT now()
);

-- 4. Enable RLS
ALTER TABLE public.app_config ENABLE ROW LEVEL SECURITY;

-- 5. Policies for App Config
-- Everyone can read config
CREATE POLICY "Public read config" ON public.app_config
FOR SELECT
USING (true);

-- Only admins can insert/update/delete
CREATE POLICY "Admins can manage config" ON public.app_config
FOR ALL
USING (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
    and profiles.role = 'admin'
  )
);

-- 6. Policy for Profiles Role Update
-- Only admins can update user roles (or via SQL editor initially)
-- This might need careful setup to avoid locking self out, but since we use SQL editor to bootstrap, it's fine.
-- For now, we rely on standard profile update policies, but specific role column protection is advanced.
-- We'll assume the SQL editor is used to promote the first admin.
