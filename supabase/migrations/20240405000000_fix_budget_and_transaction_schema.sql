-- Drop existing triggers and functions
DROP TRIGGER IF EXISTS update_budget_on_transaction_insert ON transactions;
DROP TRIGGER IF EXISTS update_budget_on_transaction_update ON transactions;
DROP TRIGGER IF EXISTS update_budget_on_transaction_delete ON transactions;
DROP FUNCTION IF EXISTS update_budget_spent_amount();

-- Create function to update budget spent amount
CREATE OR REPLACE FUNCTION update_budget_spent_amount()
RETURNS TRIGGER AS $$
DECLARE
    transaction_month DATE;
BEGIN
    -- Get the month of the transaction
    transaction_month := date_trunc('month', COALESCE(NEW.date, OLD.date))::date;

    -- Create or update main category budget
    INSERT INTO budgets (
        user_id,
        expense_category_id,
        month,
        spent_amount,
        allocated_amount
    )
    VALUES (
        COALESCE(NEW.user_id, OLD.user_id),
        COALESCE(NEW.expense_category_id, OLD.expense_category_id),
        transaction_month,
        COALESCE(
            (SELECT SUM(amount)
             FROM transactions
             WHERE user_id = COALESCE(NEW.user_id, OLD.user_id)
             AND expense_category_id = COALESCE(NEW.expense_category_id, OLD.expense_category_id)
             AND expense_subcategory_id IS NULL
             AND date_trunc('month', date)::date = transaction_month
            ), 0
        ),
        COALESCE(
            (SELECT allocated_amount 
             FROM budgets 
             WHERE user_id = COALESCE(NEW.user_id, OLD.user_id)
             AND expense_category_id = COALESCE(NEW.expense_category_id, OLD.expense_category_id)
             AND expense_subcategory_id IS NULL
             AND month = transaction_month
            ), 0
        )
    )
    ON CONFLICT (user_id, expense_category_id, expense_subcategory_id, month)
    DO UPDATE SET
        spent_amount = EXCLUDED.spent_amount,
        allocated_amount = EXCLUDED.allocated_amount;

    -- If subcategory exists, create or update subcategory budget
    IF COALESCE(NEW.expense_subcategory_id, OLD.expense_subcategory_id) IS NOT NULL THEN
        INSERT INTO budgets (
            user_id,
            expense_category_id,
            expense_subcategory_id,
            month,
            spent_amount,
            allocated_amount
        )
        VALUES (
            COALESCE(NEW.user_id, OLD.user_id),
            COALESCE(NEW.expense_category_id, OLD.expense_category_id),
            COALESCE(NEW.expense_subcategory_id, OLD.expense_subcategory_id),
            transaction_month,
            COALESCE(
                (SELECT SUM(amount)
                 FROM transactions
                 WHERE user_id = COALESCE(NEW.user_id, OLD.user_id)
                 AND expense_category_id = COALESCE(NEW.expense_category_id, OLD.expense_category_id)
                 AND expense_subcategory_id = COALESCE(NEW.expense_subcategory_id, OLD.expense_subcategory_id)
                 AND date_trunc('month', date)::date = transaction_month
                ), 0
            ),
            COALESCE(
                (SELECT allocated_amount 
                 FROM budgets 
                 WHERE user_id = COALESCE(NEW.user_id, OLD.user_id)
                 AND expense_category_id = COALESCE(NEW.expense_category_id, OLD.expense_category_id)
                 AND expense_subcategory_id = COALESCE(NEW.expense_subcategory_id, OLD.expense_subcategory_id)
                 AND month = transaction_month
                ), 0
            )
        )
        ON CONFLICT (user_id, expense_category_id, expense_subcategory_id, month)
        DO UPDATE SET
            spent_amount = EXCLUDED.spent_amount,
            allocated_amount = EXCLUDED.allocated_amount;
    END IF;

    RETURN COALESCE(NEW, OLD);
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