-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.app_config (
  key text NOT NULL,
  value boolean DEFAULT false,
  description text,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT app_config_pkey PRIMARY KEY (key)
);
CREATE TABLE public.comments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  post_id uuid,
  author_id uuid,
  content text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT comments_pkey PRIMARY KEY (id),
  CONSTRAINT comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id),
  CONSTRAINT comments_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.companies (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  tier USER-DEFINED NOT NULL DEFAULT 'intermediary'::company_tier,
  description text,
  logo_url text,
  address text,
  contact_phone text,
  balance numeric DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'active'::text, 'rejected'::text])),
  allows_b2b boolean DEFAULT true,
  allows_b2c boolean DEFAULT true,
  currency_id uuid,
  CONSTRAINT companies_pkey PRIMARY KEY (id),
  CONSTRAINT companies_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.currencies(id)
);
CREATE TABLE public.company_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL,
  name text NOT NULL,
  color_hex text DEFAULT '#000000'::text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT company_categories_pkey PRIMARY KEY (id),
  CONSTRAINT company_categories_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id)
);
CREATE TABLE public.company_members (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  company_id uuid,
  user_id uuid,
  role USER-DEFINED DEFAULT 'staff'::user_role,
  permissions jsonb DEFAULT '[]'::jsonb,
  joined_at timestamp with time zone DEFAULT now(),
  roles ARRAY DEFAULT '{staff}'::text[],
  CONSTRAINT company_members_pkey PRIMARY KEY (id),
  CONSTRAINT company_members_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id),
  CONSTRAINT company_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.company_subscriptions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL,
  plan_id uuid NOT NULL,
  start_date timestamp with time zone DEFAULT now(),
  end_date timestamp with time zone NOT NULL,
  status text DEFAULT 'active'::text CHECK (status = ANY (ARRAY['active'::text, 'expired'::text, 'cancelled'::text])),
  payment_ref text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT company_subscriptions_pkey PRIMARY KEY (id),
  CONSTRAINT company_subscriptions_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id),
  CONSTRAINT company_subscriptions_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.subscription_plans(id)
);
CREATE TABLE public.currencies (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  code text NOT NULL,
  symbol text NOT NULL,
  is_default boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT currencies_pkey PRIMARY KEY (id)
);
CREATE TABLE public.customers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL,
  full_name text NOT NULL,
  phone_number text,
  email text,
  address text,
  balance numeric DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  total_sales numeric DEFAULT 0,
  total_paid numeric DEFAULT 0,
  last_payment_date timestamp with time zone,
  buyer_company_id uuid,
  CONSTRAINT customers_pkey PRIMARY KEY (id),
  CONSTRAINT customers_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id),
  CONSTRAINT customers_buyer_company_id_fkey FOREIGN KEY (buyer_company_id) REFERENCES public.companies(id)
);
CREATE TABLE public.delivery_options (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL,
  name text NOT NULL,
  cost numeric NOT NULL DEFAULT 0,
  estimated_days_min integer,
  estimated_days_max integer,
  description text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT delivery_options_pkey PRIMARY KEY (id),
  CONSTRAINT delivery_options_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id)
);
CREATE TABLE public.expenses (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL,
  amount numeric NOT NULL,
  category text NOT NULL,
  description text,
  date timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT expenses_pkey PRIMARY KEY (id),
  CONSTRAINT expenses_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id)
);
CREATE TABLE public.financial_transactions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL,
  type text NOT NULL CHECK (type = ANY (ARRAY['income'::text, 'expense'::text])),
  category text NOT NULL,
  amount numeric NOT NULL DEFAULT 0,
  description text,
  payment_method text DEFAULT 'cash'::text,
  reference_id uuid,
  date timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT financial_transactions_pkey PRIMARY KEY (id),
  CONSTRAINT financial_transactions_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id)
);
CREATE TABLE public.global_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  icon_key text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT global_categories_pkey PRIMARY KEY (id)
);
CREATE TABLE public.notifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  title text NOT NULL,
  body text NOT NULL,
  type text DEFAULT 'info'::text,
  is_read boolean DEFAULT false,
  related_entity_type text,
  related_entity_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT notifications_pkey PRIMARY KEY (id),
  CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.offer_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  title text DEFAULT 'Solar System Request'::text,
  pv_total double precision DEFAULT 0,
  battery_total double precision DEFAULT 0,
  inverter_total double precision DEFAULT 0,
  notes text,
  specs jsonb DEFAULT '{}'::jsonb,
  status USER-DEFINED DEFAULT 'open'::request_status,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT offer_requests_pkey PRIMARY KEY (id),
  CONSTRAINT offer_requests_profile_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.offers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  request_id uuid,
  company_id uuid,
  pv_specs jsonb DEFAULT '{}'::jsonb,
  battery_specs jsonb DEFAULT '{}'::jsonb,
  inverter_specs jsonb DEFAULT '{}'::jsonb,
  involves jsonb DEFAULT '[]'::jsonb,
  notes text,
  price numeric NOT NULL,
  status USER-DEFINED DEFAULT 'pending'::offer_status,
  expires_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT offers_pkey PRIMARY KEY (id),
  CONSTRAINT offers_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.offer_requests(id),
  CONSTRAINT offers_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id)
);
CREATE TABLE public.order_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_id uuid,
  product_id uuid,
  quantity integer NOT NULL,
  unit_price numeric NOT NULL,
  total_line_price numeric NOT NULL,
  product_name_snapshot text,
  selected_options jsonb DEFAULT '[]'::jsonb,
  CONSTRAINT order_items_pkey PRIMARY KEY (id),
  CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id),
  CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.orders (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  seller_company_id uuid,
  buyer_user_id uuid,
  buyer_company_id uuid,
  guest_customer_name text,
  order_type USER-DEFINED NOT NULL,
  status USER-DEFINED DEFAULT 'completed'::order_status,
  payment_status USER-DEFINED DEFAULT 'paid'::payment_status,
  total_amount numeric NOT NULL,
  discount_amount numeric DEFAULT 0,
  tax_amount numeric DEFAULT 0,
  created_offline boolean DEFAULT false,
  synced_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  customer_id uuid,
  payment_method text DEFAULT 'cash'::text,
  paid_amount numeric DEFAULT 0,
  cancellation_reason text,
  offer_id uuid,
  shipping_cost numeric DEFAULT 0,
  shipping_method text,
  shipping_address jsonb,
  currency_symbol text,
  currency_code text,
  CONSTRAINT orders_pkey PRIMARY KEY (id),
  CONSTRAINT orders_seller_company_id_fkey FOREIGN KEY (seller_company_id) REFERENCES public.companies(id),
  CONSTRAINT orders_buyer_user_id_fkey FOREIGN KEY (buyer_user_id) REFERENCES public.profiles(id),
  CONSTRAINT orders_buyer_company_id_fkey FOREIGN KEY (buyer_company_id) REFERENCES public.companies(id),
  CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id),
  CONSTRAINT orders_offer_id_fkey FOREIGN KEY (offer_id) REFERENCES public.offers(id)
);
CREATE TABLE public.posts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  author_id uuid,
  content text,
  image_urls ARRAY,
  post_type text DEFAULT 'general'::text,
  likes_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  system_id uuid,
  company_id uuid,
  CONSTRAINT posts_pkey PRIMARY KEY (id),
  CONSTRAINT posts_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.profiles(id),
  CONSTRAINT posts_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id),
  CONSTRAINT fk_post_system FOREIGN KEY (system_id) REFERENCES public.systems(id)
);
CREATE TABLE public.product_company_categories (
  product_id uuid NOT NULL,
  category_id uuid NOT NULL,
  CONSTRAINT product_company_categories_pkey PRIMARY KEY (product_id, category_id),
  CONSTRAINT link_product_fkey FOREIGN KEY (product_id) REFERENCES public.products(id),
  CONSTRAINT link_category_fkey FOREIGN KEY (category_id) REFERENCES public.company_categories(id)
);
CREATE TABLE public.product_option_values (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  option_id uuid NOT NULL,
  value text NOT NULL,
  extra_cost numeric DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT product_option_values_pkey PRIMARY KEY (id),
  CONSTRAINT product_option_values_option_id_fkey FOREIGN KEY (option_id) REFERENCES public.product_options(id)
);
CREATE TABLE public.product_options (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL,
  name text NOT NULL,
  is_required boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT product_options_pkey PRIMARY KEY (id),
  CONSTRAINT product_options_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.product_pricing_tiers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL,
  min_quantity integer NOT NULL DEFAULT 1,
  unit_price numeric NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT product_pricing_tiers_pkey PRIMARY KEY (id),
  CONSTRAINT pricing_tiers_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.products (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  company_id uuid,
  name text NOT NULL,
  sku text,
  category text,
  description text,
  image_url text,
  cost_price numeric DEFAULT 0,
  retail_price numeric DEFAULT 0,
  wholesale_price numeric DEFAULT 0,
  stock_quantity integer DEFAULT 0,
  min_stock_alert integer DEFAULT 5,
  specs jsonb DEFAULT '{}'::jsonb,
  status USER-DEFINED DEFAULT 'active'::product_status,
  created_at timestamp with time zone DEFAULT now(),
  discount numeric DEFAULT 0,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT products_pkey PRIMARY KEY (id),
  CONSTRAINT products_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  full_name text,
  phone_number text UNIQUE,
  avatar_url text,
  is_verified boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  role USER-DEFINED DEFAULT 'user'::user_type,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.replies (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  entity_id uuid NOT NULL,
  entity_type text NOT NULL,
  sender_id uuid NOT NULL,
  content text NOT NULL,
  is_read boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT replies_pkey PRIMARY KEY (id),
  CONSTRAINT replies_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.subscription_plans (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  duration_days integer NOT NULL,
  price numeric NOT NULL DEFAULT 0,
  description text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT subscription_plans_pkey PRIMARY KEY (id)
);
CREATE TABLE public.systems (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user text,
  user_status text DEFAULT 'pending'::text CHECK (user_status = ANY (ARRAY['pending'::text, 'accepted'::text, 'rejected'::text])),
  installed_by uuid,
  company_status text DEFAULT 'pending'::text CHECK (company_status = ANY (ARRAY['pending'::text, 'accepted'::text, 'rejected'::text])),
  pv jsonb DEFAULT '{}'::jsonb,
  battery jsonb DEFAULT '{}'::jsonb,
  inverter jsonb DEFAULT '{}'::jsonb,
  notes text,
  lat double precision,
  lan double precision,
  address text,
  city text,
  country text,
  installed_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  order_id uuid,
  user_id uuid,
  CONSTRAINT systems_pkey PRIMARY KEY (id),
  CONSTRAINT systems_installed_by_fkey FOREIGN KEY (installed_by) REFERENCES public.companies(id),
  CONSTRAINT systems_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id),
  CONSTRAINT systems_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT systems_user_fkey FOREIGN KEY (user) REFERENCES public.profiles(phone_number)
);