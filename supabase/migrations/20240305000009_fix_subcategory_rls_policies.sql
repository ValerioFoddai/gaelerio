-- Drop existing RLS policies
DROP POLICY IF EXISTS "Subcategories can be updated by anyone" ON public.expense_subcategories;
DROP POLICY IF EXISTS "Subcategories are viewable by everyone" ON public.expense_subcategories;

-- Create more specific RLS policies
CREATE POLICY "Subcategories are viewable by authenticated users"
    ON public.expense_subcategories
    FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Subcategories can be updated by authenticated users"
    ON public.expense_subcategories
    FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Add policy for position updates
CREATE POLICY "Position updates are allowed for authenticated users"
    ON public.expense_subcategories
    FOR UPDATE
    USING (
        auth.role() = 'authenticated' AND
        (OLD.position IS DISTINCT FROM NEW.position)
    )
    WITH CHECK (
        auth.role() = 'authenticated' AND
        (OLD.position IS DISTINCT FROM NEW.position)
    );

-- Ensure proper grants
GRANT SELECT, UPDATE ON public.expense_subcategories TO authenticated;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';