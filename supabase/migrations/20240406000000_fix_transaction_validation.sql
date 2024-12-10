-- Drop existing triggers and functions
DROP TRIGGER IF EXISTS validate_transaction_subcategory ON public.transactions;
DROP FUNCTION IF EXISTS validate_transaction_subcategory();

-- Create improved function to validate subcategory
CREATE OR REPLACE FUNCTION validate_transaction_subcategory()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.expense_subcategory_id IS NOT NULL THEN
        -- Use EXISTS instead of subquery in expression
        IF NOT EXISTS (
            SELECT 1 
            FROM public.expense_subcategories
            WHERE id = NEW.expense_subcategory_id
            AND main_category_id = NEW.expense_category_id
            LIMIT 1
        ) THEN
            RAISE EXCEPTION 'Invalid subcategory for the selected category';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for subcategory validation
CREATE TRIGGER validate_transaction_subcategory
    BEFORE INSERT OR UPDATE ON public.transactions
    FOR EACH ROW
    EXECUTE FUNCTION validate_transaction_subcategory();

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';