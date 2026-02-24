-- Add cancellation_reason column
ALTER TABLE public.orders 
ADD COLUMN IF NOT EXISTS cancellation_reason text;

-- Add new enum values for order_status
-- Note: You cannot add values inside a transaction block usually, so run these one by one if it fails.
ALTER TYPE public.order_status ADD VALUE IF NOT EXISTS 'waiting';
ALTER TYPE public.order_status ADD VALUE IF NOT EXISTS 'in_progress';
ALTER TYPE public.order_status ADD VALUE IF NOT EXISTS 'done';
ALTER TYPE public.order_status ADD VALUE IF NOT EXISTS 'canceled';
