-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

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
  CONSTRAINT companies_pkey PRIMARY KEY (id)
);
CREATE TABLE public.company_members (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  company_id uuid,
  user_id uuid,
  role USER-DEFINED DEFAULT 'staff'::user_role,
  permissions jsonb DEFAULT '[]'::jsonb,
  joined_at timestamp with time zone DEFAULT now(),
  CONSTRAINT company_members_pkey PRIMARY KEY (id),
  CONSTRAINT company_members_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id),
  CONSTRAINT company_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
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
  title text NOT NULL,
  description text,
  requirements jsonb DEFAULT '{}'::jsonb,
  location_city text,
  image_urls ARRAY,
  status USER-DEFINED DEFAULT 'open'::request_status,
  created_at timestamp with time zone DEFAULT now(),
  details jsonb DEFAULT '{}'::jsonb,
  CONSTRAINT offer_requests_pkey PRIMARY KEY (id),
  CONSTRAINT offer_requests_profile_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.offers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  request_id uuid,
  company_id uuid,
  price numeric NOT NULL,
  notes text,
  status USER-DEFINED DEFAULT 'pending'::offer_status,
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
  CONSTRAINT orders_pkey PRIMARY KEY (id),
  CONSTRAINT orders_seller_company_id_fkey FOREIGN KEY (seller_company_id) REFERENCES public.companies(id),
  CONSTRAINT orders_buyer_user_id_fkey FOREIGN KEY (buyer_user_id) REFERENCES public.profiles(id),
  CONSTRAINT orders_buyer_company_id_fkey FOREIGN KEY (buyer_company_id) REFERENCES public.companies(id)
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
  CONSTRAINT posts_pkey PRIMARY KEY (id),
  CONSTRAINT posts_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.profiles(id),
  CONSTRAINT posts_system_id_fkey FOREIGN KEY (system_id) REFERENCES public.solar_systems(id)
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
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.solar_systems (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  owner_id uuid,
  installed_by_company_id uuid,
  verification_status USER-DEFINED DEFAULT 'pending_verification'::system_status,
  system_name text,
  location_coordinates point,
  total_capacity_kw numeric,
  image_url text,
  specs jsonb DEFAULT '{}'::jsonb,
  notes text,
  installation_date date,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT solar_systems_pkey PRIMARY KEY (id),
  CONSTRAINT solar_systems_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.profiles(id),
  CONSTRAINT solar_systems_installed_by_company_id_fkey FOREIGN KEY (installed_by_company_id) REFERENCES public.companies(id)
);