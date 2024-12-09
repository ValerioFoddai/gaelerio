-- Drop existing policies
DROP POLICY IF EXISTS "Categories are viewable by authenticated users" ON public.expense_main_categories;
DROP POLICY IF EXISTS "Categories can be updated by authenticated users" ON public.expense_main_categories;
DROP POLICY IF EXISTS "Subcategories are viewable by authenticated users" ON public.expense_subcategories;
DROP POLICY IF EXISTS "Subcategories can be updated by authenticated users" ON public.expense_subcategories;

-- Create improved RLS policies for main categories
CREATE POLICY "Categories are viewable by everyone"
    ON public.expense_main_categories
    FOR SELECT
    USING (true);

CREATE POLICY "Categories can be updated by anyone"
    ON public.expense_main_categories
    FOR UPDATE
    USING (true);

-- Create improved RLS policies for subcategories
CREATE POLICY "Subcategories are viewable by everyone"
    ON public.expense_subcategories
    FOR SELECT
    USING (true);

CREATE POLICY "Subcategories can be updated by anyone"
    ON public.expense_subcategories
    FOR UPDATE
    USING (true);

-- Grant proper permissions
GRANT ALL ON public.expense_main_categories TO authenticated;
GRANT ALL ON public.expense_subcategories TO authenticated;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';