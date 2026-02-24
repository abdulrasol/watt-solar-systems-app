-- Add discount column to products table
ALTER TABLE public.products
ADD COLUMN discount numeric DEFAULT 0;

COMMENT ON COLUMN public.products.discount IS 'Fixed discount amount in currency (e.g., $10)';
