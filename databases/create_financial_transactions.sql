-- Create Financial Transactions Table
-- Tracks income and expenses including customer payments.

CREATE TABLE IF NOT EXISTS public.financial_transactions (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  company_id uuid NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  
  type text NOT NULL CHECK (type IN ('income', 'expense')), -- income or expense
  category text NOT NULL, -- e.g., 'customer_payment', 'salary', 'rent', 'purchase'
  
  amount numeric NOT NULL DEFAULT 0,
  description text,
  
  payment_method text DEFAULT 'cash', -- cash, bank_transfer, etc.
  
  reference_id uuid, -- Optional link to other tables (e.g. customer_id, order_id)
  
  date timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now()
);

-- RLS
ALTER TABLE public.financial_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read/write for company members" ON public.financial_transactions
AS PERMISSIVE FOR ALL
TO authenticated
USING (
  company_id IN (
    SELECT company_id FROM public.company_members 
    WHERE user_id = auth.uid()
  )
);
