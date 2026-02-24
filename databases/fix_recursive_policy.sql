-- FIX: Drop the recursive policy that caused the crash
DROP POLICY IF EXISTS "View team members" ON public.company_members;

-- Ensure the safe policy is in place (idempotent)
DROP POLICY IF EXISTS "Users can view own membership" ON public.company_members;

CREATE POLICY "Users can view own membership" ON public.company_members
FOR SELECT
USING (auth.uid() = user_id);

-- Optional: If you really need to view other members, you often need a Security Definer function
-- or a separate lookup to avoid recursion. For now, this unblocks the app.
