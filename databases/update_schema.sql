-- ==========================================
-- Update Schema Script
-- Run this in Supabase SQL Editor
-- ==========================================

-- 1. Update company_members to reference auth.users
ALTER TABLE company_members DROP CONSTRAINT IF EXISTS company_members_user_id_fkey;
ALTER TABLE company_members
ADD CONSTRAINT company_members_user_id_fkey
FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- 2. Add 'details' column to offer_requests
-- The app uses 'details' to store the full system JSON when requesting an offer.
ALTER TABLE offer_requests 
ADD COLUMN IF NOT EXISTS details JSONB DEFAULT '{}';

-- 3. Update offer_requests to reference auth.users (Consistency)
ALTER TABLE offer_requests DROP CONSTRAINT IF EXISTS offer_requests_user_id_fkey;
ALTER TABLE offer_requests
ADD CONSTRAINT offer_requests_user_id_fkey
FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- 4. Enable RLS on offer_requests if not enabled (Safety)
ALTER TABLE offer_requests ENABLE ROW LEVEL SECURITY;
