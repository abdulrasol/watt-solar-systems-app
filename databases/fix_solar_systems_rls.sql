-- Enable RLS on solar_systems
ALTER TABLE public.solar_systems ENABLE ROW LEVEL SECURITY;

-- 1. Users can manage their own systems (where they are the owner)
DROP POLICY IF EXISTS "Users can manage own systems" ON public.solar_systems;
CREATE POLICY "Users can manage own systems" ON public.solar_systems
FOR ALL
USING (auth.uid() = owner_id)
WITH CHECK (auth.uid() = owner_id);

-- 2. Company members can manage systems installed by their company
-- This allows staff to add/edit systems for customers.
DROP POLICY IF EXISTS "Company members can manage company systems" ON public.solar_systems;
CREATE POLICY "Company members can manage company systems" ON public.solar_systems
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.company_members 
    WHERE company_id = solar_systems.installed_by_company_id 
    AND user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.company_members 
    WHERE company_id = solar_systems.installed_by_company_id 
    AND user_id = auth.uid()
  )
);
