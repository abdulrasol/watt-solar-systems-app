-- Fix relationships between systems and profiles tables

-- 1. Ensure user_id column exists (it might be missing if systems_rebuild.sql was run)
ALTER TABLE public.systems ADD COLUMN IF NOT EXISTS user_id uuid;

-- 2. Backfill user_id from profiles based on phone number ("user" column)
-- This ensures existing systems linked by phone are now linked by ID
UPDATE public.systems s
SET user_id = p.id
FROM public.profiles p
WHERE s.user = p.phone_number 
  AND s.user_id IS NULL;

-- 3. Add Foreign Key for user_id -> profiles(id)
-- We drop existing constraint just in case
ALTER TABLE public.systems DROP CONSTRAINT IF EXISTS systems_user_id_fkey;
ALTER TABLE public.systems ADD CONSTRAINT systems_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES public.profiles(id);

-- Optional: If you want to ALSO keep the Foreign Key on the phone number column ("user"),
-- uncomment the lines below. However, having two Foreign Keys to the same table 
-- requires specifying which one to use in your API selects (ambiguous embedding).
-- For now, we prefer migrating to user_id.

-- ALTER TABLE public.systems DROP CONSTRAINT IF EXISTS systems_user_fkey;
-- ALTER TABLE public.systems ADD CONSTRAINT systems_user_fkey 
--    FOREIGN KEY ("user") REFERENCES public.profiles(phone_number);

-- 4. Reload schema cache
NOTIFY pgrst, 'reload schema';
