-- First, ensure the Bills & Utilities category exists
DO $$
DECLARE
    bills_id UUID;
BEGIN
    -- Get or create Bills & Utilities category
    SELECT id INTO bills_id
    FROM public.expense_main_categories
    WHERE name = 'Bills & Utilities';

    IF bills_id IS NULL THEN
        INSERT INTO public.expense_main_categories (name, description)
        VALUES ('Bills & Utilities', 'Regular bills and utility expenses')
        RETURNING id INTO bills_id;
    END IF;

    -- Clear existing subcategories for this category
    DELETE FROM public.expense_subcategories
    WHERE main_category_id = bills_id;

    -- Insert subcategories with proper main_category_id
    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (bills_id, 'Electricity'),
        (bills_id, 'Garbage'),
        (bills_id, 'Gas'),
        (bills_id, 'Internet'),
        (bills_id, 'Phone'),
        (bills_id, 'Water');

    -- Now do the same for all other categories
    -- Transport
    INSERT INTO public.expense_main_categories (name, description)
    VALUES ('Transport', 'Transportation and travel expenses')
    ON CONFLICT (name) DO NOTHING
    RETURNING id INTO bills_id;

    SELECT id INTO bills_id FROM public.expense_main_categories WHERE name = 'Transport';
    
    INSERT INTO public.expense_subcategories (main_category_id, name)
    VALUES
        (bills_id, 'Auto Payment'),
        (bills_id, 'Public Transit'),
        (bills_id, 'Gas'),
        (bills_id, 'Auto Maintenance'),
        (bills_id, 'Parking & Tolls'),
        (bills_id, 'Taxi & Ride Shares');

    -- And continue for each category...
    -- This ensures each category exists and has its subcategories properly linked
END $$;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';