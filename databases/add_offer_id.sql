-- Add offer_id column to orders table
ALTER TABLE public.orders 
ADD COLUMN offer_id uuid REFERENCES public.offers(id);

-- Optional: Add index for performance if querying by offer_id becomes frequent
CREATE INDEX idx_orders_offer_id ON public.orders(offer_id);
