-- 1. Add company_id column to posts table
ALTER TABLE public.posts 
ADD COLUMN IF NOT EXISTS company_id uuid REFERENCES public.companies(id);

-- 2. Add Index for performance
CREATE INDEX IF NOT EXISTS idx_posts_company_id ON public.posts(company_id);

-- 3. Update RLS Policies for Posts
-- Enable Read Access for Everyone (already likely exists, but ensuring)
DROP POLICY IF EXISTS "Public Read Posts" ON public.posts;
CREATE POLICY "Public Read Posts" ON public.posts FOR SELECT TO public USING (true);

-- Enable Insert for Users (Self) - Existing logic usually relies on author_id
DROP POLICY IF EXISTS "User Create Post" ON public.posts;
CREATE POLICY "User Create Post" ON public.posts FOR INSERT TO authenticated 
WITH CHECK (
    auth.uid() = author_id 
    AND company_id IS NULL -- Users post as themselves
);

-- Enable Insert for Company Members (Owner/Admin/Marketing)
DROP POLICY IF EXISTS "Company Create Post" ON public.posts;
CREATE POLICY "Company Create Post" ON public.posts FOR INSERT TO authenticated 
WITH CHECK (
    company_id IS NOT NULL 
    AND EXISTS (
        SELECT 1 FROM public.company_members 
        WHERE company_members.company_id = posts.company_id 
        AND company_members.user_id = auth.uid()
        AND company_members.role IN ('owner', 'admin', 'manager', 'sales', 'marketing')
    )
);

-- Enable Update/Delete for Authors OR Company Admins
DROP POLICY IF EXISTS "Modify Own Or Company Post" ON public.posts;
CREATE POLICY "Modify Own Or Company Post" ON public.posts FOR ALL TO authenticated 
USING (
    -- Author can modify own post
    auth.uid() = author_id 
    OR 
    -- Company Admin/Owner can modify company post
    (
        company_id IS NOT NULL 
        AND EXISTS (
            SELECT 1 FROM public.company_members 
            WHERE company_members.company_id = posts.company_id 
            AND company_members.user_id = auth.uid()
            AND company_members.role IN ('owner', 'admin', 'manager')
        )
    )
);
