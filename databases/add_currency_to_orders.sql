-- Add currency columns to orders table to persist historical currency data
ALTER TABLE public.orders 
ADD COLUMN currency_symbol text,
ADD COLUMN currency_code text;

-- Optional: Backfill existing orders with default '$' and 'USD' if needed
-- UPDATE public.orders SET currency_symbol = '$', currency_code = 'USD' WHERE currency_symbol IS NULL;
