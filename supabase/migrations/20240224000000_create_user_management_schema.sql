-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "citext";

-- Create enum types
CREATE TYPE account_status AS ENUM ('active', 'inactive', 'suspended');
CREATE TYPE notification_frequency AS ENUM ('never', 'daily', 'weekly', 'monthly');
CREATE TYPE privacy_level AS ENUM ('private', 'friends', 'public');

-- Core user profiles table (extends auth.users)
CREATE TABLE public.user_profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    username CITEXT UNIQUE,
    first_name TEXT,
    last_name TEXT,
    date_of_birth DATE,
    profile_picture_url TEXT,
    last_login_at TIMESTAMP WITH TIME ZONE,
    account_status account_status DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT proper_age CHECK (date_of_birth <= CURRENT_DATE - INTERVAL '13 years'),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- User contact details
CREATE TABLE public.user_contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    phone_number TEXT,
    street_address TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    postal_code TEXT,
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Security and authentication
CREATE TABLE public.user_security (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE UNIQUE,
    password_reset_token TEXT,
    token_expires_at TIMESTAMP WITH TIME ZONE,
    two_factor_enabled BOOLEAN DEFAULT false,
    two_factor_secret TEXT,
    last_password_change TIMESTAMP WITH TIME ZONE,
    failed_login_attempts INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- User preferences
CREATE TABLE public.user_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE UNIQUE,
    language TEXT DEFAULT 'en',
    timezone TEXT DEFAULT 'UTC',
    email_notifications notification_frequency DEFAULT 'weekly',
    privacy_level privacy_level DEFAULT 'private',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Social media links
CREATE TABLE public.user_social_links (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    platform TEXT NOT NULL,
    url TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at),
    UNIQUE(user_id, platform)
);

-- User metadata (for custom fields)
CREATE TABLE public.user_metadata (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    key TEXT NOT NULL,
    value JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at),
    UNIQUE(user_id, key)
);

-- Create indexes for better query performance
CREATE INDEX idx_user_profiles_username ON public.user_profiles(username);
CREATE INDEX idx_user_profiles_account_status ON public.user_profiles(account_status);
CREATE INDEX idx_user_contacts_user_id ON public.user_contacts(user_id);
CREATE INDEX idx_user_security_user_id ON public.user_security(user_id);
CREATE INDEX idx_user_preferences_user_id ON public.user_preferences(user_id);
CREATE INDEX idx_user_social_links_user_id ON public.user_social_links(user_id);
CREATE INDEX idx_user_metadata_user_id ON public.user_metadata(user_id);
CREATE INDEX idx_user_metadata_key ON public.user_metadata(key);

-- Enable Row Level Security (RLS)
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_security ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_social_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_metadata ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies

-- user_profiles policies
CREATE POLICY "Users can view their own profile"
    ON public.user_profiles
    FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON public.user_profiles
    FOR UPDATE
    USING (auth.uid() = id);

-- user_contacts policies
CREATE POLICY "Users can view their own contacts"
    ON public.user_contacts
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own contacts"
    ON public.user_contacts
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own contacts"
    ON public.user_contacts
    FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own contacts"
    ON public.user_contacts
    FOR DELETE
    USING (auth.uid() = user_id);

-- user_security policies
CREATE POLICY "Users can view their own security settings"
    ON public.user_security
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own security settings"
    ON public.user_security
    FOR UPDATE
    USING (auth.uid() = user_id);

-- user_preferences policies
CREATE POLICY "Users can view their own preferences"
    ON public.user_preferences
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own preferences"
    ON public.user_preferences
    FOR UPDATE
    USING (auth.uid() = user_id);

-- user_social_links policies
CREATE POLICY "Users can view their own social links"
    ON public.user_social_links
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their own social links"
    ON public.user_social_links
    FOR ALL
    USING (auth.uid() = user_id);

-- user_metadata policies
CREATE POLICY "Users can view their own metadata"
    ON public.user_metadata
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their own metadata"
    ON public.user_metadata
    FOR ALL
    USING (auth.uid() = user_id);

-- Create functions for handling timestamps
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create triggers for updated_at
CREATE TRIGGER set_updated_at_user_profiles
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_user_contacts
    BEFORE UPDATE ON public.user_contacts
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_user_security
    BEFORE UPDATE ON public.user_security
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_user_preferences
    BEFORE UPDATE ON public.user_preferences
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_user_social_links
    BEFORE UPDATE ON public.user_social_links
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_user_metadata
    BEFORE UPDATE ON public.user_metadata
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Create function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Create user profile
    INSERT INTO public.user_profiles (id, username, first_name, last_name)
    VALUES (
        NEW.id,
        LOWER(SPLIT_PART(NEW.email, '@', 1)), -- Default username from email
        COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'last_name', '')
    );

    -- Create default preferences
    INSERT INTO public.user_preferences (user_id)
    VALUES (NEW.id);

    -- Create security record
    INSERT INTO public.user_security (user_id)
    VALUES (NEW.id);

    RETURN NEW;
END;
$$;

-- Create trigger for new user creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO postgres, anon, authenticated, service_role;

-- Refresh schema cache
NOTIFY pgrst, 'reload schema';