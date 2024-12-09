-- Add electricity subcategory to Bills & Utilities
INSERT INTO public.expense_subcategories (main_category_id, name, description)
SELECT 
    id as main_category_id,
    'Electricity' as name,
    'Electricity utility expense' as description
FROM public.expense_main_categories
WHERE name = 'Bills & Utilities';

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';