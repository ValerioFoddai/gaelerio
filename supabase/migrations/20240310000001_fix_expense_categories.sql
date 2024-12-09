```sql
-- Drop existing tables if they exist
DROP TABLE IF EXISTS public.expense_subcategories CASCADE;
DROP TABLE IF EXISTS public.expense_main_categories CASCADE;

-- Create main categories table
CREATE TABLE public.expense_main_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    CONSTRAINT unique_main_category_name UNIQUE (name),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Create subcategories table
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

-- Insert all categories and subcategories
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
    INSERT INTO public.expense_main_categories (name)
    VALUES ('Income')
    RETURNING id INTO income_id;

    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (income_id, 'Business Income'),
        (income_id, 'Interest'),
        (income_id, 'Other Income'),
        (income_id, 'Paychecks'),
        (income_id, 'Rent Income');

    -- Auto & Transport
    INSERT INTO public.expense_main_categories (name)
    VALUES ('Auto & Transport')
    RETURNING id INTO transport_id;

    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (transport_id, 'Auto Insurance'),
        (transport_id, 'Car Loan'),
        (transport_id, 'Car Maintenance'),
        (transport_id, 'Fuel'),
        (transport_id, 'Parking & Tolls'),
        (transport_id, 'Public Transport'),
        (transport_id, 'Taxi & Ride Shares'),
        (transport_id, 'Vehicle Registration & Taxes');

    -- Bills
    INSERT INTO public.expense_main_categories (name)
    VALUES ('Bills')
    RETURNING id INTO bills_id;

    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (bills_id, 'Cable TV'),
        (bills_id, 'Electricity'),
        (bills_id, 'Garbage'),
        (bills_id, 'Gas'),
        (bills_id, 'Home Security'),
        (bills_id, 'Internet'),
        (bills_id, 'Phone'),
        (bills_id, 'Streaming Services'),
        (bills_id, 'Water');

    -- Children
    INSERT INTO public.expense_main_categories (name)
    VALUES ('Children')
    RETURNING id INTO children_id;

    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (children_id, 'Baby Supplies'),
        (children_id, 'Child Activities'),
        (children_id, 'Child Care'),
        (children_id, 'Clothing & Accessories'),
        (children_id, 'Education'),
        (children_id, 'Healthcare'),
        (children_id, 'Toys & Games');

    -- Education
    INSERT INTO public.expense_main_categories (name)
    VALUES ('Education')
    RETURNING id INTO education_id;

    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (education_id, 'Books & Supplies'),
        (education_id, 'Courses & Training'),
        (education_id, 'Extracurricular Activities'),
        (education_id, 'Online Learning'),
        (education_id, 'Student Loans'),
        (education_id, 'Tuition Fees');

    -- Financial
    INSERT INTO public.expense_main_categories (name)
    VALUES ('Financial')
    RETURNING id INTO financial_id;

    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (financial_id, 'Banking Services'),
        (financial_id, 'Cash & ATM'),
        (financial_id, 'Debt Payments'),
        (financial_id, 'Financial & Legal Services'),
        (financial_id, 'Financial Fees'),
        (financial_id, 'Investments'),
        (financial_id, 'Loan Interest'),
        (financial_id, 'Loan Repayment'),
        (financial_id, 'Savings Contributions'),
        (financial_id, 'Taxes');

    -- Food
    INSERT INTO public.expense_main_categories (name)
    VALUES ('Food')
    RETURNING id INTO food_id;

    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (food_id, 'Groceries'),
        (food_id, 'Restaurants & Bars');

    -- Health & Wellness
    INSERT INTO public.expense_main_categories (name)
    VALUES ('Health & Wellness')
    RETURNING id INTO health_id;

    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (health_id, 'Alternative Medicine'),
        (health_id, 'Dentist'),
        (health_id, 'Fitness'),
        (health_id, 'Health Insurance'),
        (health_id, 'Medical'),
        (health_id, 'Mental Health'),
        (health_id, 'Pharmacy & Medications'),
        (health_id, 'Vision Care'),
        (health_id, 'Wellness & Spa');

    -- House
    INSERT INTO public.expense_main_categories (name)
    VALUES ('House')
    RETURNING id INTO house_id;

    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (house_id, 'Condominium Fees'),
        (house_id, 'Home Improvement'),
        (house_id, 'Home Insurance'),
        (house_id, 'Mortgage'),
        (house_id, 'Property Tax'),
        (house_id, 'Rent');

    -- Shopping
    INSERT INTO public.expense_main_categories (name)
    VALUES ('Shopping')
    RETURNING id INTO shopping_id;

    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (shopping_id, 'Beauty & Personal Care'),
        (shopping_id, 'Books & Stationery'),
        (shopping_id, 'Clothing'),
        (shopping_id, 'Electronics'),
        (shopping_id, 'Furniture'),
        (shopping_id, 'Gifts'),
        (shopping_id, 'Home & Garden'),
        (shopping_id, 'Sports & Outdoor');

    -- Transfer
    INSERT INTO public.expense_main_categories (name)
    VALUES ('Transfer')
    RETURNING id INTO transfer_id;

    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (transfer_id, 'Balance Adjustments'),
        (transfer_id, 'Credit Card Payment'),
        (transfer_id, 'External Transfer'),
        (transfer_id, 'Internal Transfer'),
        (transfer_id, 'Loan Transfers'),
        (transfer_id, 'Peer-to-Peer Transfers'),
        (transfer_id, 'Savings Transfer');

    -- Travel & Lifestyle
    INSERT INTO public.expense_main_categories (name)
    VALUES ('Travel & Lifestyle')
    RETURNING id INTO travel_id;

    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (travel_id, 'Accommodation'),
        (travel_id, 'Cultural Experiences'),
        (travel_id, 'Entertainments'),
        (travel_id, 'Fitness & Wellness'),
        (travel_id, 'Flight'),
        (travel_id, 'Hobbies'),
        (travel_id, 'Tours & Activities'),
        (travel_id, 'Vacations');
END $$;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';
```