-- Clear existing data
TRUNCATE public.expense_subcategories CASCADE;
TRUNCATE public.expense_main_categories CASCADE;

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

-- Transport subcategories
INSERT INTO public.expense_subcategories (main_category_id, name, description)
SELECT 
    id as main_category_id,
    unnest(ARRAY[
        'Auto Payment',
        'Public Transit',
        'Gas',
        'Auto Maintenance',
        'Parking & Tolls',
        'Taxi & Ride Shares'
    ]) as name,
    'Transport-related expense' as description
FROM public.expense_main_categories
WHERE name = 'Transport';

-- Housing subcategories
INSERT INTO public.expense_subcategories (main_category_id, name, description)
SELECT 
    id as main_category_id,
    unnest(ARRAY[
        'Mortgage',
        'Rent',
        'Home Improvement'
    ]) as name,
    'Housing-related expense' as description
FROM public.expense_main_categories
WHERE name = 'Housing';

-- Bills & Utilities subcategories
INSERT INTO public.expense_subcategories (main_category_id, name, description)
SELECT 
    id as main_category_id,
    unnest(ARRAY[
        'Garbage',
        'Water',
        'Gas & Electric',
        'Internet & Cable',
        'Phone'
    ]) as name,
    'Utility-related expense' as description
FROM public.expense_main_categories
WHERE name = 'Bills & Utilities';

-- Food & Dining subcategories
INSERT INTO public.expense_subcategories (main_category_id, name, description)
SELECT 
    id as main_category_id,
    unnest(ARRAY[
        'Groceries',
        'Restaurants & Bars',
        'Coffee Shops'
    ]) as name,
    'Food and dining expense' as description
FROM public.expense_main_categories
WHERE name = 'Food & Dining';

-- Travel & Lifestyle subcategories
INSERT INTO public.expense_subcategories (main_category_id, name, description)
SELECT 
    id as main_category_id,
    unnest(ARRAY[
        'Travel & Vacation',
        'Entertainment & Recreation',
        'Personal'
    ]) as name,
    'Travel and lifestyle expense' as description
FROM public.expense_main_categories
WHERE name = 'Travel & Lifestyle';

-- Shopping subcategories
INSERT INTO public.expense_subcategories (main_category_id, name, description)
SELECT 
    id as main_category_id,
    unnest(ARRAY[
        'General Shopping',
        'Clothing',
        'Furniture & Housewares',
        'Electronics'
    ]) as name,
    'Shopping expense' as description
FROM public.expense_main_categories
WHERE name = 'Shopping';

-- Children subcategories
INSERT INTO public.expense_subcategories (main_category_id, name, description)
SELECT 
    id as main_category_id,
    unnest(ARRAY[
        'Child Care',
        'Child Activities'
    ]) as name,
    'Child-related expense' as description
FROM public.expense_main_categories
WHERE name = 'Children';

-- Education subcategories
INSERT INTO public.expense_subcategories (main_category_id, name, description)
SELECT 
    id as main_category_id,
    unnest(ARRAY[
        'Student Loans',
        'General Education'
    ]) as name,
    'Education expense' as description
FROM public.expense_main_categories
WHERE name = 'Education';

-- Health & Wellness subcategories
INSERT INTO public.expense_subcategories (main_category_id, name, description)
SELECT 
    id as main_category_id,
    unnest(ARRAY[
        'Medical',
        'Dentist',
        'Fitness'
    ]) as name,
    'Health and wellness expense' as description
FROM public.expense_main_categories
WHERE name = 'Health & Wellness';

-- Financial subcategories
INSERT INTO public.expense_subcategories (main_category_id, name, description)
SELECT 
    id as main_category_id,
    unnest(ARRAY[
        'Loan Repayment',
        'Financial & Legal Services',
        'Financial Fees',
        'Cash & ATM',
        'Insurance',
        'Taxes'
    ]) as name,
    'Financial expense' as description
FROM public.expense_main_categories
WHERE name = 'Financial';

-- Business subcategories
INSERT INTO public.expense_subcategories (main_category_id, name, description)
SELECT 
    id as main_category_id,
    unnest(ARRAY[
        'Advertising & Promotion',
        'Business Utilities & Communication',
        'Employee Wages & Contract Labor',
        'Business Travel & Meals',
        'Business Auto Expenses',
        'Business Insurance',
        'Office Supplies & Expenses',
        'Office Rent',
        'Postage & Shipping'
    ]) as name,
    'Business expense' as description
FROM public.expense_main_categories
WHERE name = 'Business';

-- Transfers subcategories
INSERT INTO public.expense_subcategories (main_category_id, name, description)
SELECT 
    id as main_category_id,
    unnest(ARRAY[
        'Transfer',
        'Credit Card Payment',
        'Balance Adjustments'
    ]) as name,
    'Transfer and adjustment' as description
FROM public.expense_main_categories
WHERE name = 'Transfers';

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';