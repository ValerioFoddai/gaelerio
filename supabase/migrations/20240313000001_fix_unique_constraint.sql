-- Drop existing tables if they exist
DROP TABLE IF EXISTS public.custom_subcategories CASCADE;
DROP TABLE IF EXISTS public.custom_categories CASCADE;

-- Create custom categories table
CREATE TABLE public.custom_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Use standard unique constraint
    UNIQUE (user_id, name),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Create custom subcategories table
CREATE TABLE public.custom_subcategories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES public.custom_categories(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id),
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Use standard unique constraint
    UNIQUE (category_id, name),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Create indexes
CREATE INDEX idx_custom_categories_user ON public.custom_categories(user_id);
CREATE INDEX idx_custom_subcategories_category ON public.custom_subcategories(category_id);
CREATE INDEX idx_custom_subcategories_user ON public.custom_subcategories(user_id);

-- Enable RLS
ALTER TABLE public.custom_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.custom_subcategories ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for custom_categories
CREATE POLICY "Users can view their own custom categories"
    ON public.custom_categories FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own custom categories"
    ON public.custom_categories FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own custom categories"
    ON public.custom_categories FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own custom categories"
    ON public.custom_categories FOR DELETE
    USING (auth.uid() = user_id);

-- Create RLS policies for custom_subcategories
CREATE POLICY "Users can view their own custom subcategories"
    ON public.custom_subcategories FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own custom subcategories"
    ON public.custom_subcategories FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own custom subcategories"
    ON public.custom_subcategories FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own custom subcategories"
    ON public.custom_subcategories FOR DELETE
    USING (auth.uid() = user_id);

-- Grant permissions
GRANT ALL ON public.custom_categories TO authenticated;
GRANT ALL ON public.custom_subcategories TO authenticated;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';