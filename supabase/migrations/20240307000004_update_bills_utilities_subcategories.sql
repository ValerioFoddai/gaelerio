-- First, get the Bills & Utilities category ID and update its subcategories
DO $$
DECLARE
    bills_category_id UUID;
BEGIN
    -- Get the category ID
    SELECT id INTO bills_category_id
    FROM public.expense_main_categories 
    WHERE name = 'Bills & Utilities';

    -- Remove existing subcategories
    DELETE FROM public.expense_subcategories
    WHERE main_category_id = bills_category_id;

    -- Insert new subcategories
    INSERT INTO public.expense_subcategories (main_category_id, name, description)
    VALUES
        (bills_category_id, 'Electricity', 'Electricity (Luce)'),
        (bills_category_id, 'Garbage', 'Garbage (Spazzatura)'),
        (bills_category_id, 'Gas', 'Gas (Gas)'),
        (bills_category_id, 'Internet', 'Internet (Internet)'),
        (bills_category_id, 'Phone', 'Phone (Telefono)'),
        (bills_category_id, 'Water', 'Water (Acqua)');
END $$;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';