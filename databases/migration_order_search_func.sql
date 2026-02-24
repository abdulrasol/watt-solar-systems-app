-- Function to expose order_number as text for partial searching
-- This allows using 'order_number_str.ilike.%123%' in PostgREST

CREATE OR REPLACE FUNCTION order_number_str(orders) RETURNS text AS $$
  SELECT $1.order_number::text;
$$ LANGUAGE SQL IMMUTABLE;
