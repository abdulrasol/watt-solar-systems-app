-- Debug Script to check permissions
-- Run this in Supabase SQL Editor to see why the policy might be failing

-- 1. Check who you are authenticated as
SELECT auth.uid() as my_user_id;

-- 2. Check if you are in the company_members table for this company
-- Replace '95c5c390-670a-4e75-8be0-8df49249b811' with the company ID from the log if different
SELECT * 
FROM company_members 
WHERE user_id = auth.uid();

-- 3. Check specific RLS logic manually
SELECT 
  id as company_id, 
  name,
  (
    SELECT count(*) 
    FROM company_members 
    WHERE company_members.company_id = companies.id 
    AND company_members.user_id = auth.uid() 
    AND (
       company_members.role::text = 'owner' 
       OR company_members.role::text = 'manager'
    )
  ) as has_permission
FROM companies
WHERE id = '95c5c390-670a-4e75-8be0-8df49249b811';

-- 4. Check what the role actually is stored as (to catch enum vs text mismatches)
SELECT role, role::text, pg_typeof(role) FROM company_members WHERE user_id = auth.uid();
