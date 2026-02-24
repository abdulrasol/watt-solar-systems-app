-- Add status column to companies table
ALTER TABLE public.companies ADD COLUMN IF NOT EXISTS status text DEFAULT 'pending';

-- Add check constraint for status values
ALTER TABLE public.companies ADD CONSTRAINT companies_status_check CHECK (status IN ('pending', 'active', 'rejected'));

-- Update existing companies to active (optional, assuming current ones are verified)
UPDATE public.companies SET status = 'active' WHERE status = 'pending';
