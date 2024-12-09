-- Drop and recreate tag_categories table with proper RLS
DROP TABLE IF EXISTS public.tags CASCADE;
DROP TABLE IF EXISTS public.tag_categories CASCADE;

-- Create tag_categories table
CREATE TABLE public.tag_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    CONSTRAINT unique_category_name_per_user UNIQUE (user_id, name),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Create tags table
CREATE TABLE public.tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES public.tag_categories(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id),
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    CONSTRAINT unique_tag_name_per_category UNIQUE (category_id, name),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Create indexes
CREATE INDEX idx_tag_categories_user ON public.tag_categories(user_id);
CREATE INDEX idx_tags_category ON public.tags(category_id);
CREATE INDEX idx_tags_user ON public.tags(user_id);

-- Enable RLS
ALTER TABLE public.tag_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for tag_categories
CREATE POLICY "Users can view their own tag categories"
    ON public.tag_categories 
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own tag categories"
    ON public.tag_categories 
    FOR INSERT
    WITH CHECK (
        auth.uid() = user_id AND
        auth.role() = 'authenticated'
    );

CREATE POLICY "Users can update their own tag categories"
    ON public.tag_categories 
    FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own tag categories"
    ON public.tag_categories 
    FOR DELETE
    USING (auth.uid() = user_id);

-- Create RLS policies for tags
CREATE POLICY "Users can view their own tags"
    ON public.tags 
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own tags"
    ON public.tags 
    FOR INSERT
    WITH CHECK (
        auth.uid() = user_id AND
        auth.role() = 'authenticated'
    );

CREATE POLICY "Users can update their own tags"
    ON public.tags 
    FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own tags"
    ON public.tags 
    FOR DELETE
    USING (auth.uid() = user_id);

-- Grant proper permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON public.tag_categories TO authenticated;
GRANT ALL ON public.tags TO authenticated;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';