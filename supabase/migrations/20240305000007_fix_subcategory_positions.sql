-- Add position column to expense_subcategories if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'expense_subcategories' 
        AND column_name = 'position'
    ) THEN
        ALTER TABLE public.expense_subcategories
        ADD COLUMN position INTEGER;
    END IF;
END $$;

-- Update existing records with sequential positions
WITH numbered_subcategories AS (
    SELECT 
        id,
        main_category_id,
        ROW_NUMBER() OVER (
            PARTITION BY main_category_id 
            ORDER BY created_at, name
        ) as new_position
    FROM public.expense_subcategories
)
UPDATE public.expense_subcategories
SET position = numbered_subcategories.new_position
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
DROP TRIGGER IF EXISTS handle_subcategory_position_change ON public.expense_subcategories;
CREATE TRIGGER handle_subcategory_position_change
    BEFORE UPDATE ON public.expense_subcategories
    FOR EACH ROW
    WHEN (OLD.position IS DISTINCT FROM NEW.position)
    EXECUTE FUNCTION public.handle_subcategory_position_change();

-- Update RLS policies to allow position updates
DROP POLICY IF EXISTS "Subcategories can be updated by anyone" ON public.expense_subcategories;
CREATE POLICY "Subcategories can be updated by anyone"
    ON public.expense_subcategories
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';