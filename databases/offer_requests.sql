-- =============================================================================
-- Feature: Offer Requests (Marketplace)
-- Users can request custom quotes, and Companies can reply with offers.
-- =============================================================================

-- 1. ENUM: Status of the Request
CREATE TYPE request_status AS ENUM ('open', 'closed', 'completed');

-- 2. ENUM: Status of the Offer
CREATE TYPE offer_status AS ENUM ('pending', 'accepted', 'rejected');

-- 3. Table: Offer Requests (What the user wants)
CREATE TABLE offer_requests (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE, -- The customer
  
  title TEXT NOT NULL, -- e.g., "Need 10kW Inverter"
  description TEXT,
  
  -- Flexible specs: e.g., {"preferred_brand": "Growatt", "budget": 1000}
  requirements JSONB DEFAULT '{}', 
  
  location_city TEXT, -- To help companies filter relevant requests
  image_urls TEXT[], -- Photos of the site or old equipment
  
  status request_status DEFAULT 'open',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Table: Offers (What companies reply)
CREATE TABLE offers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  request_id UUID REFERENCES offer_requests(id) ON DELETE CASCADE,
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE, -- The company making the offer
  
  price DECIMAL NOT NULL,
  notes TEXT, -- "Includes installation and 2 year warranty"
  
  status offer_status DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Constraint: A company can make only one offer per request (or allow multiple?)
  -- For simplicity, let's say one offer per request per company.
  UNIQUE(request_id, company_id)
);

-- 5. RLS Policies (Security)
ALTER TABLE offer_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE offers ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can read open requests
CREATE POLICY "Public read open requests" ON offer_requests
  FOR SELECT USING (status = 'open' OR auth.uid() = user_id);

-- Policy: Users can create requests
CREATE POLICY "Users create requests" ON offer_requests
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy: Companies can create offers
-- (Assuming we verify company membership in the app or via a more complex policy)
CREATE POLICY "Companies create offers" ON offers
  FOR INSERT WITH CHECK (true); -- In prod, check if auth.uid() is in company_members

-- Policy: Users can see offers on *their* requests
CREATE POLICY "Users see offers on their requests" ON offers
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM offer_requests 
      WHERE offer_requests.id = offers.request_id 
      AND offer_requests.user_id = auth.uid()
    )
  );

-- Policy: Companies can see their own offers
CREATE POLICY "Companies see own offers" ON offers
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM company_members
      WHERE company_members.company_id = offers.company_id
      AND company_members.user_id = auth.uid()
    )
  );
