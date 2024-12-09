-- Drop existing tables if they exist
DROP TABLE IF EXISTS public.expense_subcategories CASCADE;
DROP TABLE IF EXISTS public.expense_main_categories CASCADE;

-- Create main categories table
CREATE TABLE public.expense_main_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    user_id UUID REFERENCES auth.users(id),
    is_system BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    CONSTRAINT unique_category_name_per_user UNIQUE NULLS NOT DISTINCT (user_id, name),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Create subcategories table
CREATE TABLE public.expense_subcategories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    main_category_id UUID NOT NULL REFERENCES public.expense_main_categories(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id),
    is_system BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    CONSTRAINT unique_subcategory_name_per_category UNIQUE NULLS NOT DISTINCT (main_category_id, name),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Create indexes
CREATE INDEX idx_main_categories_user ON public.expense_main_categories(user_id);
CREATE INDEX idx_subcategories_user ON public.expense_subcategories(user_id);
CREATE INDEX idx_subcategories_main_category ON public.expense_subcategories(main_category_id);

-- Enable RLS
ALTER TABLE public.expense_main_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expense_subcategories ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for main categories
CREATE POLICY "Users can view system categories and their own"
    ON public.expense_main_categories FOR SELECT
    USING (is_system = true OR auth.uid() = user_id);

CREATE POLICY "Users can manage their own categories"
    ON public.expense_main_categories
    FOR ALL
    USING (auth.uid() = user_id AND NOT is_system)
    WITH CHECK (auth.uid() = user_id AND NOT is_system);

-- Create RLS policies for subcategories
CREATE POLICY "Users can view system subcategories and their own"
    ON public.expense_subcategories FOR SELECT
    USING (is_system = true OR auth.uid() = user_id);

CREATE POLICY "Users can manage their own subcategories"
    ON public.expense_subcategories
    FOR ALL
    USING (auth.uid() = user_id AND NOT is_system)
    WITH CHECK (auth.uid() = user_id AND NOT is_system);

-- Grant permissions
GRANT ALL ON public.expense_main_categories TO authenticated;
GRANT ALL ON public.expense_subcategories TO authenticated;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';