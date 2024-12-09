-- First, drop all existing tables and related objects
DROP TABLE IF EXISTS public.expense_subcategories CASCADE;
DROP TABLE IF EXISTS public.expense_main_categories CASCADE;

-- Recreate main categories table with minimal structure
CREATE TABLE public.expense_main_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    CONSTRAINT unique_main_category_name UNIQUE (name),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Recreate subcategories table with minimal structure
CREATE TABLE public.expense_subcategories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    main_category_id UUID NOT NULL REFERENCES public.expense_main_categories(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    CONSTRAINT unique_subcategory_name_per_main UNIQUE (main_category_id, name),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Create indexes
CREATE INDEX idx_expense_subcategories_main_category ON public.expense_subcategories(main_category_id);

-- Enable Row Level Security
ALTER TABLE public.expense_main_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expense_subcategories ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Categories are viewable by everyone"
    ON public.expense_main_categories
    FOR SELECT
    USING (true);

CREATE POLICY "Categories can be modified by anyone"
    ON public.expense_main_categories
    FOR ALL
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Subcategories are viewable by everyone"
    ON public.expense_subcategories
    FOR SELECT
    USING (true);

CREATE POLICY "Subcategories can be modified by anyone"
    ON public.expense_subcategories
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- Grant necessary permissions
GRANT ALL ON public.expense_main_categories TO authenticated;
GRANT ALL ON public.expense_subcategories TO authenticated;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';