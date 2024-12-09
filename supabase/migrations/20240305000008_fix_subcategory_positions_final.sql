-- Drop existing position-related objects
DROP TRIGGER IF EXISTS handle_subcategory_position_change ON public.expense_subcategories;
DROP FUNCTION IF EXISTS public.handle_subcategory_position_change();

-- Create improved position handling function
CREATE OR REPLACE FUNCTION public.handle_subcategory_position_change()
RETURNS TRIGGER AS $$
DECLARE
    v_old_position INTEGER;
    v_new_position INTEGER;
BEGIN
    v_old_position := OLD.position;
    v_new_position := NEW.position;

    -- Validate positions
    IF v_new_position < 1 THEN
        RAISE EXCEPTION 'Position must be greater than 0';
    END IF;

    -- Handle position changes
    IF v_old_position != v_new_position THEN
        -- Moving down
        IF v_new_position > v_old_position THEN
            UPDATE public.expense_subcategories
            SET position = position - 1
            WHERE main_category_id = NEW.main_category_id
            AND position > v_old_position
            AND position <= v_new_position
            AND id != NEW.id;
        -- Moving up
        ELSE
            UPDATE public.expense_subcategories
            SET position = position + 1
            WHERE main_category_id = NEW.main_category_id
            AND position >= v_new_position
            AND position < v_old_position
            AND id != NEW.id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create new trigger for position updates
CREATE TRIGGER handle_subcategory_position_change
    BEFORE UPDATE ON public.expense_subcategories
    FOR EACH ROW
    WHEN (OLD.position IS DISTINCT FROM NEW.position)
    EXECUTE FUNCTION public.handle_subcategory_position_change();

-- Update RLS policies to ensure proper access
DROP POLICY IF EXISTS "Subcategories can be updated by anyone" ON public.expense_subcategories;
CREATE POLICY "Subcategories can be updated by anyone"
    ON public.expense_subcategories
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Resequence all positions to ensure consistency
WITH resequenced AS (
    SELECT 
        id,
        main_category_id,
        ROW_NUMBER() OVER (
            PARTITION BY main_category_id 
            ORDER BY position, created_at
        ) as new_position
    FROM public.expense_subcategories
)
UPDATE public.expense_subcategories
SET position = resequenced.new_position
FROM resequenced
WHERE expense_subcategories.id = resequenced.id;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';