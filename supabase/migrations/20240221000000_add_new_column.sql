-- Add new column to profiles table
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now());

-- Update existing rows to have a created_at value
UPDATE public.profiles 
SET created_at = updated_at 
WHERE created_at IS NULL;

-- Make created_at NOT NULL after setting values for existing rows
ALTER TABLE public.profiles 
ALTER COLUMN created_at SET NOT NULL;

-- Refresh schema cache
NOTIFY pgrst, 'reload schema';