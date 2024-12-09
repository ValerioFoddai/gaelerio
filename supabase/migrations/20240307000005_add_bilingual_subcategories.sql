-- First, add the new column for Italian names
ALTER TABLE public.expense_subcategories 
ADD COLUMN name_it TEXT;

-- Update the Bills & Utilities subcategories with both languages
DO $$
DECLARE
    bills_category_id UUID;
BEGIN
    -- Get the Bills & Utilities category ID
    SELECT id INTO bills_category_id
    FROM public.expense_main_categories 
    WHERE name = 'Bills & Utilities';

    -- Remove existing subcategories
    DELETE FROM public.expense_subcategories
    WHERE main_category_id = bills_category_id;

    -- Insert subcategories with both English and Italian names
    INSERT INTO public.expense_subcategories (main_category_id, name, name_it, description)
    VALUES
        (bills_category_id, 'Electricity', 'Luce', 'Utility expense'),
        (bills_category_id, 'Garbage', 'Spazzatura', 'Utility expense'),
        (bills_category_id, 'Gas', 'Gas', 'Utility expense'),
        (bills_category_id, 'Internet', 'Internet', 'Utility expense'),
        (bills_category_id, 'Phone', 'Telefono', 'Utility expense'),
        (bills_category_id, 'Water', 'Acqua', 'Utility expense');
END $$;

-- Make name_it NOT NULL after initial data is set
ALTER TABLE public.expense_subcategories 
ALTER COLUMN name_it SET NOT NULL;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';