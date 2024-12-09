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

-- Add index on position
CREATE INDEX idx_expense_subcategories_position ON public.expense_subcategories(position);

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';