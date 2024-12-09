-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create expense_main_categories table
CREATE TABLE public.expense_main_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Constraints
    CONSTRAINT unique_main_category_name UNIQUE (name),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Create expense_subcategories table
CREATE TABLE public.expense_subcategories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    main_category_id UUID NOT NULL REFERENCES public.expense_main_categories(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Constraints
    CONSTRAINT unique_subcategory_name_per_main UNIQUE (main_category_id, name),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Create indexes
CREATE INDEX idx_expense_subcategories_main_category ON public.expense_subcategories(main_category_id);

-- Create function to handle updated_at
CREATE OR REPLACE FUNCTION public.handle_expense_categories_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create triggers for updated_at
CREATE TRIGGER set_main_categories_updated_at
    BEFORE UPDATE ON public.expense_main_categories
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_expense_categories_updated_at();

CREATE TRIGGER set_subcategories_updated_at
    BEFORE UPDATE ON public.expense_subcategories
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_expense_categories_updated_at();

-- Insert default main categories
INSERT INTO public.expense_main_categories (name, description) VALUES
    ('Housing', 'Housing and accommodation expenses'),
    ('Transport', 'Transportation and travel expenses'),
    ('Food & Dining', 'Food and dining expenses'),
    ('Utilities', 'Utility bills and services'),
    ('Healthcare', 'Healthcare and medical expenses'),
    ('Entertainment', 'Entertainment and recreation'),
    ('Shopping', 'Shopping and retail expenses'),
    ('Education', 'Education and learning expenses'),
    ('Personal Care', 'Personal care and wellness'),
    ('Financial', 'Financial services and fees');

-- Insert subcategories for Housing
INSERT INTO public.expense_subcategories (main_category_id, name, description)
SELECT 
    id as main_category_id,
    unnest(ARRAY[
        'Rent',
        'Mortgage',
        'Property Tax',
        'Home Insurance',
        'Maintenance',
        'Furniture',
        'Home Improvement'
    ]) as name,
    'Housing-related expense' as description
FROM public.expense_main_categories
WHERE name = 'Housing';

-- Insert subcategories for Transport
INSERT INTO public.expense_subcategories (main_category_id, name, description)
SELECT 
    id as main_category_id,
    unnest(ARRAY[
        'Public Transit',
        'Auto Payment',
        'Gas',
        'Car Insurance',
        'Maintenance',
        'Parking',
        'Ride Share'
    ]) as name,
    'Transportation-related expense' as description
FROM public.expense_main_categories
WHERE name = 'Transport';

-- Insert subcategories for Food & Dining
INSERT INTO public.expense_subcategories (main_category_id, name, description)
SELECT 
    id as main_category_id,
    unnest(ARRAY[
        'Groceries',
        'Restaurants',
        'Coffee Shops',
        'Food Delivery',
        'Snacks'
    ]) as name,
    'Food and dining expense' as description
FROM public.expense_main_categories
WHERE name = 'Food & Dining';

-- Enable Row Level Security
ALTER TABLE public.expense_main_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expense_subcategories ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Categories are viewable by everyone"
    ON public.expense_main_categories FOR SELECT
    USING (true);

CREATE POLICY "Subcategories are viewable by everyone"
    ON public.expense_subcategories FOR SELECT
    USING (true);

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO postgres, anon, authenticated, service_role;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';