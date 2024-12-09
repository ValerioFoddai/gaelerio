-- Add spent amount column to budgets table
ALTER TABLE public.budgets
ADD COLUMN spent_amount DECIMAL(10,2) NOT NULL DEFAULT 0;

-- Create function to update budget spent amount
CREATE OR REPLACE FUNCTION update_budget_spent_amount()
RETURNS TRIGGER AS $$
DECLARE
    transaction_month DATE;
    category_spent DECIMAL(10,2);
    subcategory_spent DECIMAL(10,2);
BEGIN
    -- Get the month of the transaction
    transaction_month := date_trunc('month', NEW.date)::date;

    -- Update main category budget
    SELECT COALESCE(SUM(amount), 0) INTO category_spent
    FROM transactions
    WHERE user_id = NEW.user_id
    AND expense_category_id = NEW.expense_category_id
    AND date_trunc('month', date)::date = transaction_month;

    UPDATE budgets
    SET spent_amount = category_spent
    WHERE user_id = NEW.user_id
    AND expense_category_id = NEW.expense_category_id
    AND month = transaction_month
    AND expense_subcategory_id IS NULL;

    -- Update subcategory budget if applicable
    IF NEW.expense_subcategory_id IS NOT NULL THEN
        SELECT COALESCE(SUM(amount), 0) INTO subcategory_spent
        FROM transactions
        WHERE user_id = NEW.user_id
        AND expense_category_id = NEW.expense_category_id
        AND expense_subcategory_id = NEW.expense_subcategory_id
        AND date_trunc('month', date)::date = transaction_month;

        UPDATE budgets
        SET spent_amount = subcategory_spent
        WHERE user_id = NEW.user_id
        AND expense_category_id = NEW.expense_category_id
        AND expense_subcategory_id = NEW.expense_subcategory_id
        AND month = transaction_month;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for transaction changes
CREATE TRIGGER update_budget_on_transaction_insert
    AFTER INSERT ON transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_budget_spent_amount();

CREATE TRIGGER update_budget_on_transaction_update
    AFTER UPDATE ON transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_budget_spent_amount();

-- Create function to handle transaction deletion
CREATE OR REPLACE FUNCTION update_budget_on_transaction_delete()
RETURNS TRIGGER AS $$
DECLARE
    transaction_month DATE;
    category_spent DECIMAL(10,2);
    subcategory_spent DECIMAL(10,2);
BEGIN
    -- Get the month of the deleted transaction
    transaction_month := date_trunc('month', OLD.date)::date;

    -- Update main category budget
    SELECT COALESCE(SUM(amount), 0) INTO category_spent
    FROM transactions
    WHERE user_id = OLD.user_id
    AND expense_category_id = OLD.expense_category_id
    AND date_trunc('month', date)::date = transaction_month;

    UPDATE budgets
    SET spent_amount = category_spent
    WHERE user_id = OLD.user_id
    AND expense_category_id = OLD.expense_category_id
    AND month = transaction_month
    AND expense_subcategory_id IS NULL;

    -- Update subcategory budget if applicable
    IF OLD.expense_subcategory_id IS NOT NULL THEN
        SELECT COALESCE(SUM(amount), 0) INTO subcategory_spent
        FROM transactions
        WHERE user_id = OLD.user_id
        AND expense_category_id = OLD.expense_category_id
        AND expense_subcategory_id = OLD.expense_subcategory_id
        AND date_trunc('month', date)::date = transaction_month;

        UPDATE budgets
        SET spent_amount = subcategory_spent
        WHERE user_id = OLD.user_id
        AND expense_category_id = OLD.expense_category_id
        AND expense_subcategory_id = OLD.expense_subcategory_id
        AND month = transaction_month;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for transaction deletion
CREATE TRIGGER update_budget_on_transaction_delete
    AFTER DELETE ON transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_budget_on_transaction_delete();

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';