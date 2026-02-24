-- Migration to support multi-role members
-- This adds a 'roles' column of type text array to company_members table.
-- It defaults to '{staff}' for new rows.

ALTER TABLE public.company_members 
ADD COLUMN IF NOT EXISTS roles text[] DEFAULT '{staff}';

COMMENT ON COLUMN public.company_members.roles IS 'List of roles assigned to the member (e.g. admin, manager, sales, driver)';

-- Optional: Backfill existing data if needed (uncomment if you want to migrate existing single role)
-- UPDATE public.company_members 
-- SET roles = ARRAY[role::text]
-- WHERE role IS NOT NULL;
