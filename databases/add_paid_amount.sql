-- Add paid_amount to orders to track partial payments
ALTER TABLE public.orders 
ADD COLUMN IF NOT EXISTS paid_amount numeric DEFAULT 0;

-- Optional: Update existing orders to have paid_amount = total_amount if they are 'paid'
UPDATE public.orders 
SET paid_amount = total_amount 
WHERE payment_status = 'paid' AND paid_amount = 0;
