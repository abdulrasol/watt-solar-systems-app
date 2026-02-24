-- Add shipping columns to orders
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS shipping_cost numeric DEFAULT 0;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS shipping_method text;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS shipping_address jsonb;

-- Create delivery_options table
CREATE TABLE IF NOT EXISTS public.delivery_options (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL,
  name text NOT NULL,
  cost numeric NOT NULL DEFAULT 0,
  estimated_days_min integer,
  estimated_days_max integer,
  description text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT delivery_options_pkey PRIMARY KEY (id),
  CONSTRAINT delivery_options_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id)
);

-- RLS for delivery_options
ALTER TABLE public.delivery_options ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read access" ON public.delivery_options;
CREATE POLICY "Public read access" ON public.delivery_options FOR SELECT USING (true);

DROP POLICY IF EXISTS "Company members manage delivery options" ON public.delivery_options;
CREATE POLICY "Company members manage delivery options" ON public.delivery_options
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.company_members cm
      WHERE cm.company_id = delivery_options.company_id
      AND cm.user_id = auth.uid()
      AND (
         cm.role::text = 'owner' 
         OR cm.role::text = 'manager' 
         OR cm.role::text = 'admin'
      )
    )
  );

-- Indexes
CREATE INDEX IF NOT EXISTS idx_delivery_options_company_id ON public.delivery_options(company_id);
