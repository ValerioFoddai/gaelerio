-- First, clear existing data
TRUNCATE public.expense_subcategories CASCADE;
TRUNCATE public.expense_main_categories CASCADE;

-- Insert all main categories and their subcategories
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
    INSERT INTO public.expense_main_categories (name, description, is_system)
    VALUES ('Income', 'All types of income', true)
    RETURNING id INTO income_id;

    INSERT INTO public.expense_subcategories (main_category_id, name, is_system)
    VALUES
        (income_id, 'Business Income', true),
        (income_id, 'Interest', true),
        (income_id, 'Other Income', true),
        (income_id, 'Paychecks', true),
        (income_id, 'Rent Income', true);

    -- Auto & Transport
    INSERT INTO public.expense_main_categories (name, description, is_system)
    VALUES ('Auto & Transport', 'Transportation and travel expenses', true)
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
    INSERT INTO public.expense_main_categories (name, description, is_system)
    VALUES ('Bills', 'Regular bills and utilities', true)
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
    INSERT INTO public.expense_main_categories (name, description, is_system)
    VALUES ('Children', 'Child-related expenses', true)
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
    INSERT INTO public.expense_main_categories (name, description, is_system)
    VALUES ('Education', 'Education and learning expenses', true)
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
    INSERT INTO public.expense_main_categories (name, description, is_system)
    VALUES ('Financial', 'Financial services and fees', true)
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
    INSERT INTO public.expense_main_categories (name, description, is_system)
    VALUES ('Food', 'Food and dining expenses', true)
    RETURNING id INTO food_id;

    INSERT INTO public.expense_subcategories (main_category_id, name, is_system)
    VALUES
        (food_id, 'Groceries', true),
        (food_id, 'Restaurants & Bars', true);

    -- Health & Wellness
    INSERT INTO public.expense_main_categories (name, description, is_system)
    VALUES ('Health & Wellness', 'Health and wellness expenses', true)
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
    INSERT INTO public.expense_main_categories (name, description, is_system)
    VALUES ('House', 'Housing and property expenses', true)
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
    INSERT INTO public.expense_main_categories (name, description, is_system)
    VALUES ('Shopping', 'Shopping and retail expenses', true)
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
    INSERT INTO public.expense_main_categories (name, description, is_system)
    VALUES ('Transfer', 'Money transfers and adjustments', true)
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
    INSERT INTO public.expense_main_categories (name, description, is_system)
    VALUES ('Travel & Lifestyle', 'Travel and lifestyle expenses', true)
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