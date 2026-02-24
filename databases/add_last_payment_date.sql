-- Add last_payment_date to customers table
ALTER TABLE public.customers 
ADD COLUMN IF NOT EXISTS last_payment_date timestamp with time zone;
