-- Drop existing triggers and functions
DROP TRIGGER IF EXISTS validate_transaction_subcategory ON public.transactions;
DROP FUNCTION IF EXISTS validate_transaction_subcategory();

-- Create improved function to validate subcategory
CREATE OR REPLACE FUNCTION validate_transaction_subcategory()
RETURNS TRIGGER AS $$
DECLARE
    valid_subcategory BOOLEAN;
BEGIN
    -- Only validate if subcategory is provided
    IF NEW.expense_subcategory_id IS NOT NULL THEN
        SELECT EXISTS (
            SELECT 1 
            FROM public.expense_subcategories
            WHERE id = NEW.expense_subcategory_id
            AND main_category_id = NEW.expense_category_id
        ) INTO valid_subcategory;

        IF NOT valid_subcategory THEN
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