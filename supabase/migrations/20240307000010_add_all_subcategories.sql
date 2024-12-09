-- Add all subcategories for each main category
DO $$
DECLARE
    transport_id UUID;
    housing_id UUID;
    bills_id UUID;
    food_id UUID;
    travel_id UUID;
    shopping_id UUID;
    children_id UUID;
    education_id UUID;
    health_id UUID;
    financial_id UUID;
    business_id UUID;
    transfers_id UUID;
BEGIN
    -- Get category IDs
    SELECT id INTO transport_id FROM public.expense_main_categories WHERE name = 'Transport';
    SELECT id INTO housing_id FROM public.expense_main_categories WHERE name = 'Housing';
    SELECT id INTO bills_id FROM public.expense_main_categories WHERE name = 'Bills & Utilities';
    SELECT id INTO food_id FROM public.expense_main_categories WHERE name = 'Food & Dining';
    SELECT id INTO travel_id FROM public.expense_main_categories WHERE name = 'Travel & Lifestyle';
    SELECT id INTO shopping_id FROM public.expense_main_categories WHERE name = 'Shopping';
    SELECT id INTO children_id FROM public.expense_main_categories WHERE name = 'Children';
    SELECT id INTO education_id FROM public.expense_main_categories WHERE name = 'Education';
    SELECT id INTO health_id FROM public.expense_main_categories WHERE name = 'Health & Wellness';
    SELECT id INTO financial_id FROM public.expense_main_categories WHERE name = 'Financial';
    SELECT id INTO business_id FROM public.expense_main_categories WHERE name = 'Business';
    SELECT id INTO transfers_id FROM public.expense_main_categories WHERE name = 'Transfers';

    -- Clear existing subcategories
    DELETE FROM public.expense_subcategories;

    -- Transport subcategories
    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (transport_id, 'Auto Payment'),
        (transport_id, 'Public Transit'),
        (transport_id, 'Gas'),
        (transport_id, 'Auto Maintenance'),
        (transport_id, 'Parking & Tolls'),
        (transport_id, 'Taxi & Ride Shares');

    -- Housing subcategories
    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (housing_id, 'Mortgage'),
        (housing_id, 'Rent'),
        (housing_id, 'Home Improvement');

    -- Bills & Utilities subcategories
    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (bills_id, 'Electricity'),
        (bills_id, 'Garbage'),
        (bills_id, 'Gas'),
        (bills_id, 'Internet'),
        (bills_id, 'Phone'),
        (bills_id, 'Water');

    -- Food & Dining subcategories
    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (food_id, 'Groceries'),
        (food_id, 'Restaurants & Bars'),
        (food_id, 'Coffee Shops');

    -- Travel & Lifestyle subcategories
    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (travel_id, 'Travel & Vacation'),
        (travel_id, 'Entertainment & Recreation'),
        (travel_id, 'Personal');

    -- Shopping subcategories
    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (shopping_id, 'General Shopping'),
        (shopping_id, 'Clothing'),
        (shopping_id, 'Furniture & Housewares'),
        (shopping_id, 'Electronics');

    -- Children subcategories
    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (children_id, 'Child Care'),
        (children_id, 'Child Activities');

    -- Education subcategories
    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (education_id, 'Student Loans'),
        (education_id, 'General Education');

    -- Health & Wellness subcategories
    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (health_id, 'Medical'),
        (health_id, 'Dentist'),
        (health_id, 'Fitness');

    -- Financial subcategories
    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (financial_id, 'Loan Repayment'),
        (financial_id, 'Financial & Legal Services'),
        (financial_id, 'Financial Fees'),
        (financial_id, 'Cash & ATM'),
        (financial_id, 'Insurance'),
        (financial_id, 'Taxes');

    -- Business subcategories
    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (business_id, 'Advertising & Promotion'),
        (business_id, 'Business Utilities & Communication'),
        (business_id, 'Employee Wages & Contract Labor'),
        (business_id, 'Business Travel & Meals'),
        (business_id, 'Business Auto Expenses'),
        (business_id, 'Business Insurance'),
        (business_id, 'Office Supplies & Expenses'),
        (business_id, 'Office Rent'),
        (business_id, 'Postage & Shipping');

    -- Transfers subcategories
    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (transfers_id, 'Transfer'),
        (transfers_id, 'Credit Card Payment'),
        (transfers_id, 'Balance Adjustments');
END $$;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';