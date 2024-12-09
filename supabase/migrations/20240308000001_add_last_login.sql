-- Add last_login column to profiles table
ALTER TABLE public.profiles
ADD COLUMN last_login TIMESTAMP WITH TIME ZONE;

-- Create function to update last_login
CREATE OR REPLACE FUNCTION public.handle_auth_sign_in()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.profiles
    SET last_login = now()
    WHERE id = auth.uid();
    RETURN NEW;
END;
$$;

-- Create trigger for sign in events
DROP TRIGGER IF EXISTS on_auth_sign_in ON auth.users;
CREATE TRIGGER on_auth_sign_in
    AFTER UPDATE OF last_sign_in_at ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_auth_sign_in();

-- Add index for better query performance
CREATE INDEX idx_profiles_last_login ON public.profiles(last_login);

-- Update handle_new_user function to include last_login
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
        last_login,
        created_at,
        updated_at
    )
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
        NEW.email,
        now(),
        now(),
        now()
    );
    
    RETURN NEW;
END;
$$;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';