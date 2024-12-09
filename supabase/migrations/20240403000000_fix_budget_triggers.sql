-- Drop existing triggers and functions
DROP TRIGGER IF EXISTS update_budget_on_transaction_insert ON transactions;
DROP TRIGGER IF EXISTS update_budget_on_transaction_update ON transactions;
DROP TRIGGER IF EXISTS update_budget_on_transaction_delete ON transactions;
DROP FUNCTION IF EXISTS update_budget_spent_amount();
DROP FUNCTION IF EXISTS update_budget_on_transaction_delete();

-- Create function to update budget spent amount
CREATE OR REPLACE FUNCTION update_budget_spent_amount()
RETURNS TRIGGER AS $$
BEGIN
    -- Create or update main category budget
    INSERT INTO budgets (
        user_id,
        expense_category_id,
        month,
        spent_amount,
        allocated_amount
    )
    SELECT
        NEW.user_id,
        NEW.expense_category_id,
        date_trunc('month', NEW.date)::date,
        COALESCE(
            (SELECT SUM(amount)
             FROM transactions
             WHERE user_id = NEW.user_id
             AND expense_category_id = NEW.expense_category_id
             AND date_trunc('month', date) = date_trunc('month', NEW.date)
            ), 0
        ),
        0
    ON CONFLICT (user_id, expense_category_id, month) 
    WHERE expense_subcategory_id IS NULL
    DO UPDATE SET
        spent_amount = COALESCE(
            (SELECT SUM(amount)
             FROM transactions
             WHERE user_id = NEW.user_id
             AND expense_category_id = NEW.expense_category_id
             AND date_trunc('month', date) = date_trunc('month', NEW.date)
            ), 0
        );

    -- If subcategory exists, create or update subcategory budget
    IF NEW.expense_subcategory_id IS NOT NULL THEN
        INSERT INTO budgets (
            user_id,
            expense_category_id,
            expense_subcategory_id,
            month,
            spent_amount,
            allocated_amount
        )
        SELECT
            NEW.user_id,
            NEW.expense_category_id,
            NEW.expense_subcategory_id,
            date_trunc('month', NEW.date)::date,
            COALESCE(
                (SELECT SUM(amount)
                 FROM transactions
                 WHERE user_id = NEW.user_id
                 AND expense_category_id = NEW.expense_category_id
                 AND expense_subcategory_id = NEW.expense_subcategory_id
                 AND date_trunc('month', date) = date_trunc('month', NEW.date)
                ), 0
            ),
            0
        ON CONFLICT (user_id, expense_category_id, expense_subcategory_id, month)
        DO UPDATE SET
            spent_amount = COALESCE(
                (SELECT SUM(amount)
                 FROM transactions
                 WHERE user_id = NEW.user_id
                 AND expense_category_id = NEW.expense_category_id
                 AND expense_subcategory_id = NEW.expense_subcategory_id
                 AND date_trunc('month', date) = date_trunc('month', NEW.date)
                ), 0
            );
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

CREATE TRIGGER update_budget_on_transaction_delete
    AFTER DELETE ON transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_budget_spent_amount();

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';