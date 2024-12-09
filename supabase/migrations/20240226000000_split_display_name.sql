-- First, add the new columns
ALTER TABLE public.profiles
ADD COLUMN name TEXT,
ADD COLUMN surname TEXT;

-- Create a function to split display_name into name and surname
CREATE OR REPLACE FUNCTION split_display_name()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Update the name field (first word of display_name)
    UPDATE public.profiles
    SET name = COALESCE(
        SPLIT_PART(TRIM(display_name), ' ', 1),
        'Anonymous'
    )
    WHERE name IS NULL;

    -- Update the surname field (everything after the first word)
    UPDATE public.profiles
    SET surname = NULLIF(
        TRIM(
            SUBSTRING(
                TRIM(display_name) 
                FROM LENGTH(SPLIT_PART(TRIM(display_name), ' ', 1)) + 2
            )
        ),
        ''
    )
    WHERE surname IS NULL;
END;
$$;

-- Execute the split function
SELECT split_display_name();

-- Make name column NOT NULL and add constraint
UPDATE public.profiles
SET name = 'Anonymous'
WHERE name IS NULL;

ALTER TABLE public.profiles
ALTER COLUMN name SET NOT NULL,
ADD CONSTRAINT name_not_empty CHECK (LENGTH(TRIM(name)) > 0);

-- Drop the split function as it's no longer needed
DROP FUNCTION split_display_name();

-- Update the handle_new_user function to use the new fields
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.profiles (
        id,
        name,
        surname,
        created_at,
        updated_at
    )
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'name', 'Anonymous'),
        NEW.raw_user_meta_data->>'surname',
        now(),
        now()
    );
    
    RETURN NEW;
END;
$$;

-- Add a function to combine name and surname for backward compatibility
CREATE OR REPLACE FUNCTION get_full_name(p public.profiles)
RETURNS TEXT
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT 
        CASE 
            WHEN p.surname IS NOT NULL AND p.surname != '' 
            THEN p.name || ' ' || p.surname
            ELSE p.name
        END;
$$;

-- Create a view for backward compatibility
CREATE OR REPLACE VIEW public.profile_view AS
SELECT 
    p.*,
    get_full_name(p) as display_name
FROM public.profiles p;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON public.profiles TO authenticated;
GRANT ALL ON public.profile_view TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_full_name TO authenticated;

-- Refresh schema cache
NOTIFY pgrst, 'reload schema';