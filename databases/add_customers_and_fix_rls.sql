-- Create Customers Table
CREATE TABLE IF NOT EXISTS public.customers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL,
  full_name text NOT NULL,
  phone_number text,
  email text,
  address text,
  balance numeric DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT customers_pkey PRIMARY KEY (id),
  CONSTRAINT customers_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id)
);

-- RLS for Customers
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read/write for company members" ON public.customers
AS PERMISSIVE FOR ALL
TO authenticated
USING (
  company_id IN (
    SELECT company_id FROM public.company_members 
    WHERE user_id = auth.uid()
  )
);

-- FIX ORDERS RLS
-- The error "new row violates row-level security policy for table orders" usually means no INSERT policy exists.
-- We'll add a permissive policy for company members.

CREATE POLICY "Enable insert for company members" ON public.orders
AS PERMISSIVE FOR INSERT
TO authenticated
WITH CHECK (
  seller_company_id IN (
    SELECT company_id FROM public.company_members 
    WHERE user_id = auth.uid()
  )
);

-- Add customer_id to orders if not exists (for linking sales to customers)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'customer_id') THEN
        ALTER TABLE public.orders ADD COLUMN customer_id uuid REFERENCES public.customers(id);
    END IF;
END
$$;
