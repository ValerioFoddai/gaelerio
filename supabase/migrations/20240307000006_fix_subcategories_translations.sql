-- First, ensure all existing subcategories have a default Italian name
UPDATE public.expense_subcategories
SET name_it = name
WHERE name_it IS NULL;

-- Update all subcategories with proper translations
DO $$
DECLARE
    category_id UUID;
BEGIN
    -- Bills & Utilities
    SELECT id INTO category_id
    FROM public.expense_main_categories 
    WHERE name = 'Bills & Utilities';

    -- Update Bills & Utilities subcategories
    UPDATE public.expense_subcategories
    SET name_it = CASE name
        WHEN 'Electricity' THEN 'Luce'
        WHEN 'Garbage' THEN 'Spazzatura'
        WHEN 'Gas' THEN 'Gas'
        WHEN 'Internet' THEN 'Internet'
        WHEN 'Phone' THEN 'Telefono'
        WHEN 'Water' THEN 'Acqua'
        ELSE name -- Fallback to English name if no translation
    END
    WHERE main_category_id = category_id;

    -- Transport
    SELECT id INTO category_id
    FROM public.expense_main_categories 
    WHERE name = 'Transport';

    -- Update Transport subcategories
    UPDATE public.expense_subcategories
    SET name_it = CASE name
        WHEN 'Auto Payment' THEN 'Rata Auto'
        WHEN 'Public Transit' THEN 'Trasporto Pubblico'
        WHEN 'Gas' THEN 'Carburante'
        WHEN 'Auto Maintenance' THEN 'Manutenzione Auto'
        WHEN 'Parking & Tolls' THEN 'Parcheggio & Pedaggi'
        WHEN 'Taxi & Ride Shares' THEN 'Taxi & Ride Sharing'
        ELSE name
    END
    WHERE main_category_id = category_id;

    -- Continue with other categories...
    -- Housing
    SELECT id INTO category_id
    FROM public.expense_main_categories 
    WHERE name = 'Housing';

    UPDATE public.expense_subcategories
    SET name_it = CASE name
        WHEN 'Mortgage' THEN 'Mutuo'
        WHEN 'Rent' THEN 'Affitto'
        WHEN 'Home Improvement' THEN 'Ristrutturazione'
        ELSE name
    END
    WHERE main_category_id = category_id;

    -- Food & Dining
    SELECT id INTO category_id
    FROM public.expense_main_categories 
    WHERE name = 'Food & Dining';

    UPDATE public.expense_subcategories
    SET name_it = CASE name
        WHEN 'Groceries' THEN 'Spesa'
        WHEN 'Restaurants & Bars' THEN 'Ristoranti & Bar'
        WHEN 'Coffee Shops' THEN 'Caffetterie'
        ELSE name
    END
    WHERE main_category_id = category_id;

    -- And so on for other categories...
END $$;

-- Now make name_it NOT NULL
ALTER TABLE public.expense_subcategories 
ALTER COLUMN name_it SET NOT NULL;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';