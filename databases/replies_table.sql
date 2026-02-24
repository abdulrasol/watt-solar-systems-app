-- Create replies table for generic chat (offers, orders, systems)
CREATE TABLE public.replies (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  entity_id uuid NOT NULL, -- Generic ID (offer_id, order_id, system_id)
  entity_type text NOT NULL, -- 'offer', 'order', 'system'
  sender_id uuid NOT NULL,
  content text NOT NULL,
  is_read boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT replies_pkey PRIMARY KEY (id),
  CONSTRAINT replies_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.profiles(id)
);

-- Add index for faster lookups
CREATE INDEX replies_entity_idx ON public.replies (entity_id, entity_type);

-- Add RLS policies
ALTER TABLE public.replies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read access for all users" ON public.replies
FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON public.replies
FOR INSERT WITH CHECK (auth.uid() = sender_id);
