-- ==============================================================================
-- 1. GLOBAL CATEGORIES
-- Standard categories shared by all companies (e.g., Panels, Inverters)
-- ==============================================================================
CREATE TABLE public.global_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  icon_key text, -- Key for client-side icon mapping
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT global_categories_pkey PRIMARY KEY (id)
);

-- Seed initial data
INSERT INTO public.global_categories (name, icon_key) VALUES
('Solar Panels', 'solar_power'),
('Inverters', 'electrical_services'),
('Batteries', 'battery_full'),
('Cables & Wires', 'cable'),
('Mounting Structure', 'foundation'),
('Tools & Accessories', 'handyman')
ON CONFLICT (name) DO NOTHING;

ALTER TABLE public.global_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read global categories" ON public.global_categories FOR SELECT USING (true);


-- ==============================================================================
-- 2. COMPANY CATEGORIES (Tags)
-- Custom categories for specific companies (e.g., Discount, New, Summer Sale)
-- ==============================================================================
CREATE TABLE public.company_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL,
  name text NOT NULL,
  color_hex text DEFAULT '#000000',
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT company_categories_pkey PRIMARY KEY (id),
  CONSTRAINT company_categories_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE CASCADE,
  UNIQUE(company_id, name)
);

ALTER TABLE public.company_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read company categories" ON public.company_categories FOR SELECT USING (true);
CREATE POLICY "Companies manage own categories" ON public.company_categories FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.company_members 
    WHERE user_id = auth.uid() AND company_id = company_categories.company_id
  )
);


-- ==============================================================================
-- 3. PRODUCT <-> COMPANY CATEGORY LINK
-- Many-to-Many relationship because a product can have multiple tags
-- ==============================================================================
CREATE TABLE public.product_company_categories (
  product_id uuid NOT NULL,
  category_id uuid NOT NULL,
  CONSTRAINT product_company_categories_pkey PRIMARY KEY (product_id, category_id),
  CONSTRAINT link_product_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE,
  CONSTRAINT link_category_fkey FOREIGN KEY (category_id) REFERENCES public.company_categories(id) ON DELETE CASCADE
);

ALTER TABLE public.product_company_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read product tags" ON public.product_company_categories FOR SELECT USING (true);
CREATE POLICY "Companies manage product tags" ON public.product_company_categories FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.products 
    JOIN public.company_members ON products.company_id = company_members.company_id
    WHERE products.id = product_company_categories.product_id
    AND company_members.user_id = auth.uid()
  )
);


-- ==============================================================================
-- 4. PRICING TIERS
-- Quantity-based pricing (Buy X get Y price)
-- ==============================================================================
CREATE TABLE public.product_pricing_tiers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL,
  min_quantity int NOT NULL DEFAULT 1,
  unit_price numeric NOT NULL, -- The price PER UNIT when buying at least this qty
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT product_pricing_tiers_pkey PRIMARY KEY (id),
  CONSTRAINT pricing_tiers_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE,
  UNIQUE(product_id, min_quantity) -- Cannot have two rules for same quantity
);

ALTER TABLE public.product_pricing_tiers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read pricing tiers" ON public.product_pricing_tiers FOR SELECT USING (true);
CREATE POLICY "Companies manage pricing tiers" ON public.product_pricing_tiers FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.products 
    JOIN public.company_members ON products.company_id = company_members.company_id
    WHERE products.id = product_pricing_tiers.product_id
    AND company_members.user_id = auth.uid()
  )
);
