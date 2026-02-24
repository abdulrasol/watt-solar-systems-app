-- Create expenses table
CREATE TABLE IF NOT EXISTS public.expenses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    amount NUMERIC NOT NULL,
    category TEXT NOT NULL, -- 'rent', 'salaries', 'utilities', 'marketing', 'other'
    description TEXT,
    date TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Enable read access for company members" ON public.expenses
    FOR SELECT
    USING (
        company_id IN (
            SELECT company_id FROM public.company_members 
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Enable insert access for company members" ON public.expenses
    FOR INSERT
    WITH CHECK (
        company_id IN (
            SELECT company_id FROM public.company_members 
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Enable update access for company members" ON public.expenses
    FOR UPDATE
    USING (
        company_id IN (
            SELECT company_id FROM public.company_members 
            WHERE user_id = auth.uid()
        )
    )
    WITH CHECK (
        company_id IN (
            SELECT company_id FROM public.company_members 
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Enable delete access for company members" ON public.expenses
    FOR DELETE
    USING (
        company_id IN (
            SELECT company_id FROM public.company_members 
            WHERE user_id = auth.uid()
        )
    );
