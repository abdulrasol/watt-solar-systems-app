-- Add buyer_company_id to customers table for B2B linking
ALTER TABLE public.customers 
ADD COLUMN IF NOT EXISTS buyer_company_id uuid REFERENCES public.companies(id) ON DELETE SET NULL;
