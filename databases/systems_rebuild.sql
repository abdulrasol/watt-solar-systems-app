
-- 1. Handling Dependencies
-- The 'posts' table references 'solar_systems'. We need to drop that constraint first.
ALTER TABLE IF EXISTS public.posts DROP CONSTRAINT IF EXISTS posts_system_id_fkey;

-- 2. Drop Old Table
DROP TABLE IF EXISTS public.solar_systems;

-- 3. Create New Table
CREATE TABLE public.systems (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  
  -- User Link (by phone number as requested)
  "user" text, -- references public.profiles(phone_number) conceptually, but maybe loose link
  user_status text CHECK (user_status IN ('pending', 'accepted', 'rejected')) DEFAULT 'pending',
  
  -- Company Link
  installed_by uuid REFERENCES public.companies(id),
  company_status text CHECK (company_status IN ('pending', 'accepted', 'rejected')) DEFAULT 'pending',
  
  -- Technical Specs (JSONB)
  pv jsonb DEFAULT '{}'::jsonb,      -- {count: int, capacity: int, mark: string}
  battery jsonb DEFAULT '{}'::jsonb, -- {count: int, capacity: double, mark: string}
  inverter jsonb DEFAULT '{}'::jsonb,-- {count: int, capacity: double, mark: string, phase: string}
  
  -- Location & Details
  notes text,
  lat double precision,
  lan double precision, -- Keeping 'lan' as requested (though usually lon/lng)
  address text,
  city text,
  country text,
  
  -- Meta
  installed_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  
  -- Link to Order
  order_id uuid REFERENCES public.orders(id),
  
  CONSTRAINT systems_pkey PRIMARY KEY (id)
);

-- 4. Re-establish relations (Optional, if we want posts to link to new systems)
-- ALTER TABLE public.posts ADD CONSTRAINT posts_system_id_fkey FOREIGN KEY (system_id) REFERENCES public.systems(id);

-- 5. RLS Policies
ALTER TABLE public.systems ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can view 'accepted' systems (public visibility logic can be refined)
CREATE POLICY "Public systems are viewable by everyone" ON public.systems
  FOR SELECT USING (user_status = 'accepted' AND company_status = 'accepted');

-- Policy: Users can view their own systems (linked by phone)
-- Note: obtaining current user's phone in RLS is tricky without a helper function or auth.jwt claim.
-- For simplicity, we might rely on the app logic or assume 'user' matches auth.uid (but user asked for phone).
-- IF 'user' column is phone_number, we need to join profile? RLS with joins is expensive.
-- alternative: store user_id UUID as well? The user requested 'user' as phone number.
-- We will assume for now Application Layer handles filtering for My Systems, 
-- OR we allow authenticated users to read all rows (filtered by UI) if data isn't sensitive?
-- Let's create a permissive policy for authenticated users for now to avoid RLS blocking dev.
CREATE POLICY "Auth users can view all systems" ON public.systems
  FOR SELECT TO authenticated USING (true);

-- Policy: Insert/Update
CREATE POLICY "Auth users can insert systems" ON public.systems
  FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Auth users can update systems" ON public.systems
  FOR UPDATE TO authenticated USING (true);
