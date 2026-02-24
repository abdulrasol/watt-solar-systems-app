-- Drop dependent table first
DROP TABLE IF EXISTS public.offers;
DROP TABLE IF EXISTS public.offer_requests;

-- Recreate offer_requests with new specs column
CREATE TABLE public.offer_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  title text DEFAULT 'Solar System Request'::text,
  pv_total double precision DEFAULT 0,
  battery_total double precision DEFAULT 0,
  inverter_total double precision DEFAULT 0,
  notes text,
  specs jsonb DEFAULT '{}'::jsonb,
  status public.request_status DEFAULT 'open'::request_status,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT offer_requests_pkey PRIMARY KEY (id),
  CONSTRAINT offer_requests_profile_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);

-- Recreate offers with new fields
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
  status public.offer_status DEFAULT 'pending'::offer_status,
  expires_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT offers_pkey PRIMARY KEY (id),
  CONSTRAINT offers_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.offer_requests(id),
  CONSTRAINT offers_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id)
);
