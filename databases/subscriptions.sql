-- Create Subscription Plans Table
CREATE TABLE public.subscription_plans (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL, -- e.g., 'Starter - 1 Month', 'Pro - 1 Year'
  duration_days integer NOT NULL, -- 30, 180, 365
  price numeric NOT NULL DEFAULT 0,
  description text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT subscription_plans_pkey PRIMARY KEY (id)
);

-- Create Company Subscriptions Table
CREATE TABLE public.company_subscriptions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL,
  plan_id uuid NOT NULL,
  start_date timestamp with time zone DEFAULT now(),
  end_date timestamp with time zone NOT NULL,
  status text DEFAULT 'active' CHECK (status IN ('active', 'expired', 'cancelled')),
  payment_ref text, -- For storing payment transaction ID if we add real payments later
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT company_subscriptions_pkey PRIMARY KEY (id),
  CONSTRAINT company_subscriptions_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id),
  CONSTRAINT company_subscriptions_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.subscription_plans(id)
);

-- Seed Default Plans
INSERT INTO public.subscription_plans (name, duration_days, price, description) VALUES
('Monthly Plan', 30, 29.99, 'Access for 1 month.'),
('Semi-Annual Plan', 180, 149.99, 'Access for 6 months (Save 15%).'),
('Annual Plan', 365, 299.99, 'Access for 1 year (Save 20%).');
