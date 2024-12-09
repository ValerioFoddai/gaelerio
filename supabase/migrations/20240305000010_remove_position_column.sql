-- Remove position-related objects
DROP TRIGGER IF EXISTS handle_subcategory_position_change ON public.expense_subcategories;
DROP FUNCTION IF EXISTS public.handle_subcategory_position_change();
ALTER TABLE public.expense_subcategories DROP CONSTRAINT IF EXISTS unique_position_per_category;
ALTER TABLE public.expense_subcategories DROP COLUMN IF EXISTS position;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';