-- Add position column to expense_subcategories
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
BEGIN
    -- For updates that change position
    IF TG_OP = 'UPDATE' AND NEW.position != OLD.position THEN
        -- Shift other positions to make room
        IF NEW.position > OLD.position THEN
            -- Moving down: shift intermediates up
            UPDATE public.expense_subcategories
            SET position = position - 1
            WHERE main_category_id = NEW.main_category_id
            AND position <= NEW.position
            AND position > OLD.position
            AND id != NEW.id;
        ELSE
            -- Moving up: shift intermediates down
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

-- Create trigger for position updates
CREATE TRIGGER handle_subcategory_position_change
    BEFORE UPDATE ON public.expense_subcategories
    FOR EACH ROW
    WHEN (OLD.position IS DISTINCT FROM NEW.position)
    EXECUTE FUNCTION public.handle_subcategory_position_change();

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';