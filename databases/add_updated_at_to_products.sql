-- Add updated_at column to products table to support auto-update triggers
ALTER TABLE public.products 
ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone DEFAULT now();
