-- Enable RLS on systems table
ALTER TABLE public.systems ENABLE ROW LEVEL SECURITY;

-- 1. Users can manage their own systems
DROP POLICY IF EXISTS "Users can manage own systems" ON public.systems;
CREATE POLICY "Users can manage own systems" ON public.systems
FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 2. Company members can manage systems installed by their company
DROP POLICY IF EXISTS "Company members can manage company systems" ON public.systems;
CREATE POLICY "Company members can manage company systems" ON public.systems
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.company_members 
    WHERE company_id = systems.installed_by 
    AND user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.company_members 
    WHERE company_id = systems.installed_by 
    AND user_id = auth.uid()
  )
);
