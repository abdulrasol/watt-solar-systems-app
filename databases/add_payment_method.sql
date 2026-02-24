-- Add payment_method to orders table
ALTER TABLE public.orders 
ADD COLUMN IF NOT EXISTS payment_method text DEFAULT 'cash';

-- Verify other new columns are present
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'customer_id') THEN
        ALTER TABLE public.orders ADD COLUMN customer_id uuid REFERENCES public.customers(id);
    END IF;
END
$$;
