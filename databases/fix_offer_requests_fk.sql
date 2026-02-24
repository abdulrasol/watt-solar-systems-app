-- Drop the old constraint pointing to auth.users (which PostgREST can't see for joins)
ALTER TABLE public.offer_requests
DROP CONSTRAINT IF EXISTS offer_requests_user_id_fkey;

-- Add new constraint pointing to public.profiles
-- This enables PostgREST to join 'offer_requests' with 'profiles'
ALTER TABLE public.offer_requests
ADD CONSTRAINT offer_requests_profile_id_fkey
FOREIGN KEY (user_id)
REFERENCES public.profiles(id);
