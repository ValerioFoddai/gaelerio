-- Drop existing position-related objects
DROP TRIGGER IF EXISTS handle_subcategory_position_change ON public.expense_subcategories;
DROP FUNCTION IF EXISTS public.handle_subcategory_position_change();
ALTER TABLE public.expense_subcategories DROP CONSTRAINT IF EXISTS unique_position_per_category;
ALTER TABLE public.expense_subcategories DROP COLUMN IF EXISTS position;

-- Add position column
ALTER TABLE public.expense_subcategories
ADD COLUMN position INTEGER;

-- Update existing records with sequential positions
WITH numbered_subcategories AS (
  SELECT id, main_category_id, ROW_NUMBER() OVER (PARTITION BY main_category_id ORDER BY name) as row_num
  FROM public.expense_subcategories
)
UPDATE public.expense_subcategories
SET position = numbered_subcategories.row_num
FROM numbered_subcategories
WHERE expense_subcategories.id = numbered_subcategories.id;

-- Make position NOT NULL after setting initial values
ALTER TABLE public.expense_subcategories
ALTER COLUMN position SET NOT NULL;

-- Add unique constraint for position within each category
ALTER TABLE public.expense_subcategories
ADD CONSTRAINT unique_position_per_category UNIQUE (main_category_id, position);

-- Create function to handle position updates
CREATE OR REPLACE FUNCTION public.handle_subcategory_position_change()
RETURNS TRIGGER AS $$
DECLARE
    v_max_position INTEGER;
BEGIN
    -- Get max position for the category
    SELECT COALESCE(MAX(position), 0)
    INTO v_max_position
    FROM public.expense_subcategories
    WHERE main_category_id = NEW.main_category_id;

    -- For new records, set position to max + 1
    IF TG_OP = 'INSERT' THEN
        NEW.position = v_max_position + 1;
    -- For updates that change position
    ELSIF TG_OP = 'UPDATE' AND NEW.position != OLD.position THEN
        -- Validate new position
        IF NEW.position < 1 OR NEW.position > v_max_position THEN
            RAISE EXCEPTION 'Invalid position value';
        END IF;

        -- Moving down
        IF NEW.position > OLD.position THEN
            UPDATE public.expense_subcategories
            SET position = position - 1
            WHERE main_category_id = NEW.main_category_id
            AND position <= NEW.position
            AND position > OLD.position
            AND id != NEW.id;
        -- Moving up
        ELSE
            UPDATE public.expense_subcategories
            SET position = position + 1
            WHERE main_category_id = NEW.main_category_id
            AND position >= NEW.position
            AND position < OLD.position
            AND id != NEW.id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for position management
CREATE TRIGGER handle_subcategory_position_change
    BEFORE INSERT OR UPDATE ON public.expense_subcategories
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_subcategory_position_change();

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';