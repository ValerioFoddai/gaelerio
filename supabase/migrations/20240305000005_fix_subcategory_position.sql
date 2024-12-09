-- Drop existing tables if they exist
DROP TABLE IF EXISTS public.expense_subcategories CASCADE;
DROP TABLE IF EXISTS public.expense_main_categories CASCADE;

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

-- Create expense_subcategories table with position
CREATE TABLE public.expense_subcategories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    main_category_id UUID NOT NULL REFERENCES public.expense_main_categories(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    position INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Constraints
    CONSTRAINT unique_subcategory_name_per_main UNIQUE (main_category_id, name),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Create indexes
CREATE INDEX idx_expense_subcategories_main_category ON public.expense_subcategories(main_category_id);
CREATE INDEX idx_expense_subcategories_position ON public.expense_subcategories(position);

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

-- Insert main categories
INSERT INTO public.expense_main_categories (name, description) VALUES
    ('Transport', 'Transportation and travel expenses'),
    ('Housing', 'Housing and accommodation expenses'),
    ('Bills & Utilities', 'Regular bills and utility expenses'),
    ('Food & Dining', 'Food and dining expenses'),
    ('Travel & Lifestyle', 'Travel and lifestyle expenses'),
    ('Shopping', 'Shopping and retail expenses'),
    ('Children', 'Child-related expenses'),
    ('Education', 'Education and learning expenses'),
    ('Health & Wellness', 'Health and wellness expenses'),
    ('Financial', 'Financial services and expenses'),
    ('Business', 'Business-related expenses'),
    ('Transfers', 'Money transfers and adjustments');

-- Function to insert subcategories with position
CREATE OR REPLACE FUNCTION insert_subcategories(
    p_main_category_name TEXT,
    p_subcategories TEXT[],
    p_description TEXT
) RETURNS VOID AS $$
DECLARE
    v_main_category_id UUID;
    v_subcategory TEXT;
    v_position INTEGER;
BEGIN
    -- Get main category ID
    SELECT id INTO v_main_category_id
    FROM public.expense_main_categories
    WHERE name = p_main_category_name;

    -- Insert subcategories with position
    v_position := 1;
    FOREACH v_subcategory IN ARRAY p_subcategories
    LOOP
        INSERT INTO public.expense_subcategories (
            main_category_id,
            name,
            description,
            position
        ) VALUES (
            v_main_category_id,
            v_subcategory,
            p_description,
            v_position
        );
        v_position := v_position + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Insert subcategories for each main category
SELECT insert_subcategories('Transport', ARRAY[
    'Auto Payment',
    'Public Transit',
    'Gas',
    'Auto Maintenance',
    'Parking & Tolls',
    'Taxi & Ride Shares'
], 'Transport-related expense');

SELECT insert_subcategories('Housing', ARRAY[
    'Mortgage',
    'Rent',
    'Home Improvement'
], 'Housing-related expense');

SELECT insert_subcategories('Bills & Utilities', ARRAY[
    'Garbage',
    'Water',
    'Gas & Electric',
    'Internet & Cable',
    'Phone',
    'Electricity'
], 'Utility-related expense');

SELECT insert_subcategories('Food & Dining', ARRAY[
    'Groceries',
    'Restaurants & Bars',
    'Coffee Shops'
], 'Food and dining expense');

SELECT insert_subcategories('Travel & Lifestyle', ARRAY[
    'Travel & Vacation',
    'Entertainment & Recreation',
    'Personal'
], 'Travel and lifestyle expense');

SELECT insert_subcategories('Shopping', ARRAY[
    'General Shopping',
    'Clothing',
    'Furniture & Housewares',
    'Electronics'
], 'Shopping expense');

SELECT insert_subcategories('Children', ARRAY[
    'Child Care',
    'Child Activities'
], 'Child-related expense');

SELECT insert_subcategories('Education', ARRAY[
    'Student Loans',
    'General Education'
], 'Education expense');

SELECT insert_subcategories('Health & Wellness', ARRAY[
    'Medical',
    'Dentist',
    'Fitness'
], 'Health and wellness expense');

SELECT insert_subcategories('Financial', ARRAY[
    'Loan Repayment',
    'Financial & Legal Services',
    'Financial Fees',
    'Cash & ATM',
    'Insurance',
    'Taxes'
], 'Financial expense');

SELECT insert_subcategories('Business', ARRAY[
    'Advertising & Promotion',
    'Business Utilities & Communication',
    'Employee Wages & Contract Labor',
    'Business Travel & Meals',
    'Business Auto Expenses',
    'Business Insurance',
    'Office Supplies & Expenses',
    'Office Rent',
    'Postage & Shipping'
], 'Business expense');

SELECT insert_subcategories('Transfers', ARRAY[
    'Transfer',
    'Credit Card Payment',
    'Balance Adjustments'
], 'Transfer and adjustment');

-- Drop the helper function as it's no longer needed
DROP FUNCTION insert_subcategories(TEXT, TEXT[], TEXT);

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';