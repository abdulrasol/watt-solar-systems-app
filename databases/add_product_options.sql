/* ==========================================================================
   Migration: Add Product Options
   Description: Introduces table structures for product variants/options (e.g. Size, Color)
   and updates order items to store selected options.
   ========================================================================== */

-- 1. Create Product Options Table
-- Stores the option definition (e.g., "Size", "Color") linked to a product.
CREATE TABLE IF NOT EXISTS public.product_options (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  name TEXT NOT NULL, -- e.g. "Color", "Size"
  is_required BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create Product Option Values Table
-- Stores the selectable values for an option (e.g., "Red", "Blue", "Small", "Large")
CREATE TABLE IF NOT EXISTS public.product_option_values (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  option_id UUID NOT NULL REFERENCES public.product_options(id) ON DELETE CASCADE,
  value TEXT NOT NULL, -- e.g. "Red", "XL"
  extra_cost DECIMAL DEFAULT 0, -- price adjustment, e.g. +$5 for XL
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Update Order Items Table
-- Add a column to store the snapshot of selected options for a line item.
ALTER TABLE public.order_items 
ADD COLUMN IF NOT EXISTS selected_options JSONB DEFAULT '[]';

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.product_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_option_values ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies

-- Policy: Public Read Access (Everyone can see options for active products)
CREATE POLICY "Public read product options" ON public.product_options
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.products
    WHERE products.id = product_options.product_id
    AND (products.status = 'active'::product_status OR 
      EXISTS (
        SELECT 1 FROM public.company_members
        WHERE user_id = auth.uid() AND company_id = products.company_id
      )
    )
  )
);

CREATE POLICY "Public read product option values" ON public.product_option_values
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.product_options
    JOIN public.products ON products.id = product_options.product_id
    WHERE product_options.id = product_option_values.option_id
    AND (products.status = 'active'::product_status OR 
      EXISTS (
        SELECT 1 FROM public.company_members
        WHERE user_id = auth.uid() AND company_id = products.company_id
      )
    )
  )
);

-- Policy: Company Write Access (Companies manage their own options)
CREATE POLICY "Companies manage product options" ON public.product_options
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.products
    JOIN public.company_members ON company_members.company_id = products.company_id
    WHERE products.id = product_options.product_id
    AND company_members.user_id = auth.uid()
  )
) WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.products
    JOIN public.company_members ON company_members.company_id = products.company_id
    WHERE products.id = product_options.product_id
    AND company_members.user_id = auth.uid()
  )
);

CREATE POLICY "Companies manage product option values" ON public.product_option_values
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.product_options
    JOIN public.products ON products.id = product_options.product_id
    JOIN public.company_members ON company_members.company_id = products.company_id
    WHERE product_options.id = product_option_values.option_id
    AND company_members.user_id = auth.uid()
  )
) WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.product_options
    JOIN public.products ON products.id = product_options.product_id
    JOIN public.company_members ON company_members.company_id = products.company_id
    WHERE product_options.id = product_option_values.option_id
    AND company_members.user_id = auth.uid()
  )
);
