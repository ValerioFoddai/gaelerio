-- Add new columns to profiles table
ALTER TABLE public.profiles
ADD COLUMN first_name VARCHAR(100),
ADD COLUMN last_name VARCHAR(100),
ADD COLUMN email VARCHAR(255);

-- Update existing records to copy email from auth.users
UPDATE public.profiles p
SET email = u.email
FROM auth.users u
WHERE p.id = u.id;

-- Make email column NOT NULL after populating data
ALTER TABLE public.profiles
ALTER COLUMN email SET NOT NULL;

-- Add email uniqueness constraint
ALTER TABLE public.profiles
ADD CONSTRAINT unique_email UNIQUE (email);

-- Update the handle_new_user function to include new fields
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.profiles (
        id,
        first_name,
        last_name,
        email,
        created_at,
        updated_at
    )
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
        NEW.email,
        now(),
        now()
    );
    
    RETURN NEW;
END;
$$;

-- Add indexes for better query performance
CREATE INDEX idx_profiles_email ON public.profiles(email);
CREATE INDEX idx_profiles_first_name ON public.profiles(first_name);
CREATE INDEX idx_profiles_last_name ON public.profiles(last_name);

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';