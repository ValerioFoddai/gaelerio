```sql
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

-- Insert default categories
DO $$
DECLARE
    income_id UUID;
    transport_id UUID;
    bills_id UUID;
    children_id UUID;
    education_id UUID;
    financial_id UUID;
    food_id UUID;
    health_id UUID;
    house_id UUID;
    shopping_id UUID;
    transfer_id UUID;
    travel_id UUID;
BEGIN
    -- Income
    INSERT INTO public.expense_main_categories (name, is_system)
    VALUES ('Income', true)
    RETURNING id INTO income_id;

    INSERT INTO public.expense_subcategories (main_category_id, name, is_system)
    VALUES
        (income_id, 'Business Income', true),
        (income_id, 'Interest', true),
        (income_id, 'Other Income', true),
        (income_id, 'Paychecks', true),
        (income_id, 'Rent Income', true);

    -- Auto & Transport
    INSERT INTO public.expense_main_categories (name, is_system)
    VALUES ('Auto & Transport', true)
    RETURNING id INTO transport_id;

    INSERT INTO public.expense_subcategories (main_category_id, name, is_system)
    VALUES
        (transport_id, 'Auto Insurance', true),
        (transport_id, 'Car Loan', true),
        (transport_id, 'Car Maintenance', true),
        (transport_id, 'Fuel', true),
        (transport_id, 'Parking & Tolls', true),
        (transport_id, 'Public Transport', true),
        (transport_id, 'Taxi & Ride Shares', true),
        (transport_id, 'Vehicle Registration & Taxes', true);

    -- Bills
    INSERT INTO public.expense_main_categories (name, is_system)
    VALUES ('Bills', true)
    RETURNING id INTO bills_id;

    INSERT INTO public.expense_subcategories (main_category_id, name, is_system)
    VALUES
        (bills_id, 'Cable TV', true),
        (bills_id, 'Electricity', true),
        (bills_id, 'Garbage', true),
        (bills_id, 'Gas', true),
        (bills_id, 'Home Security', true),
        (bills_id, 'Internet', true),
        (bills_id, 'Phone', true),
        (bills_id, 'Streaming Services', true),
        (bills_id, 'Water', true);

    -- Children
    INSERT INTO public.expense_main_categories (name, is_system)
    VALUES ('Children', true)
    RETURNING id INTO children_id;

    INSERT INTO public.expense_subcategories (main_category_id, name, is_system)
    VALUES
        (children_id, 'Baby Supplies', true),
        (children_id, 'Child Activities', true),
        (children_id, 'Child Care', true),
        (children_id, 'Clothing & Accessories', true),
        (children_id, 'Education', true),
        (children_id, 'Healthcare', true),
        (children_id, 'Toys & Games', true);

    -- Education
    INSERT INTO public.expense_main_categories (name, is_system)
    VALUES ('Education', true)
    RETURNING id INTO education_id;

    INSERT INTO public.expense_subcategories (main_category_id, name, is_system)
    VALUES
        (education_id, 'Books & Supplies', true),
        (education_id, 'Courses & Training', true),
        (education_id, 'Extracurricular Activities', true),
        (education_id, 'Online Learning', true),
        (education_id, 'Student Loans', true),
        (education_id, 'Tuition Fees', true);

    -- Financial
    INSERT INTO public.expense_main_categories (name, is_system)
    VALUES ('Financial', true)
    RETURNING id INTO financial_id;

    INSERT INTO public.expense_subcategories (main_category_id, name, is_system)
    VALUES
        (financial_id, 'Banking Services', true),
        (financial_id, 'Cash & ATM', true),
        (financial_id, 'Debt Payments', true),
        (financial_id, 'Financial & Legal Services', true),
        (financial_id, 'Financial Fees', true),
        (financial_id, 'Investments', true),
        (financial_id, 'Loan Interest', true),
        (financial_id, 'Loan Repayment', true),
        (financial_id, 'Savings Contributions', true),
        (financial_id, 'Taxes', true);

    -- Food
    INSERT INTO public.expense_main_categories (name, is_system)
    VALUES ('Food', true)
    RETURNING id INTO food_id;

    INSERT INTO public.expense_subcategories (main_category_id, name, is_system)
    VALUES
        (food_id, 'Groceries', true),
        (food_id, 'Restaurants & Bars', true);

    -- Health & Wellness
    INSERT INTO public.expense_main_categories (name, is_system)
    VALUES ('Health & Wellness', true)
    RETURNING id INTO health_id;

    INSERT INTO public.expense_subcategories (main_category_id, name, is_system)
    VALUES
        (health_id, 'Alternative Medicine', true),
        (health_id, 'Dentist', true),
        (health_id, 'Fitness', true),
        (health_id, 'Health Insurance', true),
        (health_id, 'Medical', true),
        (health_id, 'Mental Health', true),
        (health_id, 'Pharmacy & Medications', true),
        (health_id, 'Vision Care', true),
        (health_id, 'Wellness & Spa', true);

    -- House
    INSERT INTO public.expense_main_categories (name, is_system)
    VALUES ('House', true)
    RETURNING id INTO house_id;

    INSERT INTO public.expense_subcategories (main_category_id, name, is_system)
    VALUES
        (house_id, 'Condominium Fees', true),
        (house_id, 'Home Improvement', true),
        (house_id, 'Home Insurance', true),
        (house_id, 'Mortgage', true),
        (house_id, 'Property Tax', true),
        (house_id, 'Rent', true);

    -- Shopping
    INSERT INTO public.expense_main_categories (name, is_system)
    VALUES ('Shopping', true)
    RETURNING id INTO shopping_id;

    INSERT INTO public.expense_subcategories (main_category_id, name, is_system)
    VALUES
        (shopping_id, 'Beauty & Personal Care', true),
        (shopping_id, 'Books & Stationery', true),
        (shopping_id, 'Clothing', true),
        (shopping_id, 'Electronics', true),
        (shopping_id, 'Furniture', true),
        (shopping_id, 'Gifts', true),
        (shopping_id, 'Home & Garden', true),
        (shopping_id, 'Sports & Outdoor', true);

    -- Transfer
    INSERT INTO public.expense_main_categories (name, is_system)
    VALUES ('Transfer', true)
    RETURNING id INTO transfer_id;

    INSERT INTO public.expense_subcategories (main_category_id, name, is_system)
    VALUES
        (transfer_id, 'Balance Adjustments', true),
        (transfer_id, 'Credit Card Payment', true),
        (transfer_id, 'External Transfer', true),
        (transfer_id, 'Internal Transfer', true),
        (transfer_id, 'Loan Transfers', true),
        (transfer_id, 'Peer-to-Peer Transfers', true),
        (transfer_id, 'Savings Transfer', true);

    -- Travel & Lifestyle
    INSERT INTO public.expense_main_categories (name, is_system)
    VALUES ('Travel & Lifestyle', true)
    RETURNING id INTO travel_id;

    INSERT INTO public.expense_subcategories (main_category_id, name, is_system)
    VALUES
        (travel_id, 'Accommodation', true),
        (travel_id, 'Cultural Experiences', true),
        (travel_id, 'Entertainments', true),
        (travel_id, 'Fitness & Wellness', true),
        (travel_id, 'Flight', true),
        (travel_id, 'Hobbies', true),
        (travel_id, 'Tours & Activities', true),
        (travel_id, 'Vacations', true);
END $$;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';
```