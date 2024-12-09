-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create expense_categories table
CREATE TABLE public.expense_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id), -- NULL for system categories
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_id UUID REFERENCES public.expense_categories(id),
    icon TEXT,
    color TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_system BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Constraints
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at),
    CONSTRAINT unique_category_name_per_user UNIQUE NULLS NOT DISTINCT (user_id, name)
);

-- Create indexes
CREATE INDEX idx_expense_categories_user_id ON public.expense_categories(user_id);
CREATE INDEX idx_expense_categories_parent_id ON public.expense_categories(parent_id);
CREATE INDEX idx_expense_categories_is_active ON public.expense_categories(is_active);

-- Enable RLS
ALTER TABLE public.expense_categories ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can view system categories and their own categories"
    ON public.expense_categories FOR SELECT
    USING (
        is_system = true OR
        auth.uid() = user_id
    );

CREATE POLICY "Users can insert their own categories"
    ON public.expense_categories FOR INSERT
    WITH CHECK (
        auth.uid() = user_id AND
        NOT is_system -- Users cannot create system categories
    );

CREATE POLICY "Users can update their own categories"
    ON public.expense_categories FOR UPDATE
    USING (
        auth.uid() = user_id AND
        NOT is_system -- Users cannot update system categories
    );

CREATE POLICY "Users can delete their own categories"
    ON public.expense_categories FOR DELETE
    USING (
        auth.uid() = user_id AND
        NOT is_system -- Users cannot delete system categories
    );

-- Create function to handle updated_at
CREATE OR REPLACE FUNCTION public.handle_expense_categories_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for updated_at
CREATE TRIGGER set_expense_categories_updated_at
    BEFORE UPDATE ON public.expense_categories
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_expense_categories_updated_at();

-- Create function to validate parent category
CREATE OR REPLACE FUNCTION public.validate_parent_category()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.parent_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.expense_categories
            WHERE id = NEW.parent_id
            AND (is_system = true OR user_id = NEW.user_id)
        ) THEN
            RAISE EXCEPTION 'Invalid parent category';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for parent category validation
CREATE TRIGGER validate_parent_category_trigger
    BEFORE INSERT OR UPDATE ON public.expense_categories
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_parent_category();

-- Insert default system categories
INSERT INTO public.expense_categories (name, description, is_system, is_active) VALUES
    ('Housing', 'Housing and accommodation expenses', true, true),
    ('Transportation', 'Transportation and travel expenses', true, true),
    ('Food & Dining', 'Food and dining expenses', true, true),
    ('Shopping', 'Shopping and retail expenses', true, true),
    ('Entertainment', 'Entertainment and recreation', true, true),
    ('Healthcare', 'Healthcare and medical expenses', true, true),
    ('Education', 'Education and learning expenses', true, true),
    ('Personal Care', 'Personal care and wellness', true, true),
    ('Utilities', 'Utility bills and services', true, true),
    ('Insurance', 'Insurance premiums and coverage', true, true),
    ('Savings', 'Savings and investments', true, true),
    ('Debt Payments', 'Debt and loan payments', true, true),
    ('Gifts & Donations', 'Gifts and charitable donations', true, true),
    ('Business', 'Business-related expenses', true, true),
    ('Miscellaneous', 'Other uncategorized expenses', true, true);

-- Insert subcategories for Housing
INSERT INTO public.expense_categories (name, description, parent_id, is_system, is_active)
SELECT 
    name,
    description,
    (SELECT id FROM public.expense_categories WHERE name = 'Housing' AND is_system = true),
    true,
    true
FROM (VALUES
    ('Rent', 'Monthly rental payments'),
    ('Mortgage', 'Mortgage payments'),
    ('Property Tax', 'Property tax payments'),
    ('Home Insurance', 'Home insurance premiums'),
    ('Maintenance', 'Home maintenance and repairs'),
    ('Utilities', 'Home utility payments'),
    ('Furniture', 'Furniture and home decor')
) AS subcategories(name, description);

-- Insert subcategories for Transportation
INSERT INTO public.expense_categories (name, description, parent_id, is_system, is_active)
SELECT 
    name,
    description,
    (SELECT id FROM public.expense_categories WHERE name = 'Transportation' AND is_system = true),
    true,
    true
FROM (VALUES
    ('Public Transit', 'Public transportation fares'),
    ('Car Payment', 'Car loan or lease payments'),
    ('Gas', 'Fuel expenses'),
    ('Car Insurance', 'Auto insurance premiums'),
    ('Maintenance', 'Vehicle maintenance and repairs'),
    ('Parking', 'Parking fees'),
    ('Ride Share', 'Taxi and ride-sharing services')
) AS subcategories(name, description);

-- Grant permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON public.expense_categories TO authenticated;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';