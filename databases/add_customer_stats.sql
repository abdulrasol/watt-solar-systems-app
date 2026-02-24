-- Add total_sales and total_paid columns to customers table
ALTER TABLE public.customers 
ADD COLUMN IF NOT EXISTS total_sales numeric DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_paid numeric DEFAULT 0;

-- Optional: You could run a query to backfill these from existing orders if needed
-- UPDATE public.customers c
-- SET 
--   total_sales = (SELECT COALESCE(SUM(total_amount), 0) FROM public.orders o WHERE o.customer_id = c.id),
--   total_paid = (SELECT COALESCE(SUM(paid_amount), 0) FROM public.orders o WHERE o.customer_id = c.id);
