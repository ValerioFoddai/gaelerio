-- Create admin_users table
CREATE TABLE IF NOT EXISTS public.admin_users (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    role TEXT NOT NULL CHECK (role IN ('admin', 'super_admin')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT fk_user FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Enable RLS
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

-- Create policies for admin_users table
CREATE POLICY "Admin users can view admin_users"
    ON public.admin_users
    FOR SELECT
    USING (
        auth.uid() IN (
            SELECT id FROM public.admin_users
            WHERE role IN ('admin', 'super_admin')
        )
    );

CREATE POLICY "Super admins can insert admin_users"
    ON public.admin_users
    FOR INSERT
    WITH CHECK (
        auth.uid() IN (
            SELECT id FROM public.admin_users
            WHERE role = 'super_admin'
        )
    );

CREATE POLICY "Super admins can update admin_users"
    ON public.admin_users
    FOR UPDATE
    USING (
        auth.uid() IN (
            SELECT id FROM public.admin_users
            WHERE role = 'super_admin'
        )
    );

-- Create function to check if user is admin
CREATE OR REPLACE FUNCTION public.is_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM public.admin_users
        WHERE id = user_id
        AND role IN ('admin', 'super_admin')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to check if user is super admin
CREATE OR REPLACE FUNCTION public.is_super_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM public.admin_users
        WHERE id = user_id
        AND role = 'super_admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO postgres, anon, authenticated, service_role;

-- Refresh schema cache
NOTIFY pgrst, 'reload schema';