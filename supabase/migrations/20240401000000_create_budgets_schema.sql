-- Create budgets table
CREATE TABLE public.budgets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    expense_category_id UUID NOT NULL REFERENCES public.expense_main_categories(id),
    expense_subcategory_id UUID REFERENCES public.expense_subcategories(id),
    month DATE NOT NULL,
    allocated_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Basic constraints
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at),
    CONSTRAINT valid_amount CHECK (allocated_amount >= 0),
    -- Ensure unique budget per user, category, and month
    UNIQUE(user_id, expense_category_id, expense_subcategory_id, month)
);

-- Create function to validate subcategory relationship
CREATE OR REPLACE FUNCTION validate_budget_subcategory()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.expense_subcategory_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.expense_subcategories
            WHERE id = NEW.expense_subcategory_id
            AND main_category_id = NEW.expense_category_id
        ) THEN
            RAISE EXCEPTION 'Invalid subcategory for the selected category';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for subcategory validation
CREATE TRIGGER validate_budget_subcategory
    BEFORE INSERT OR UPDATE ON public.budgets
    FOR EACH ROW
    EXECUTE FUNCTION validate_budget_subcategory();

-- Create function to handle updated_at
CREATE OR REPLACE FUNCTION handle_budgets_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
CREATE TRIGGER set_budgets_updated_at
    BEFORE UPDATE ON public.budgets
    FOR EACH ROW
    EXECUTE FUNCTION handle_budgets_updated_at();

-- Create indexes
CREATE INDEX idx_budgets_user ON public.budgets(user_id);
CREATE INDEX idx_budgets_category ON public.budgets(expense_category_id);
CREATE INDEX idx_budgets_subcategory ON public.budgets(expense_subcategory_id);
CREATE INDEX idx_budgets_month ON public.budgets(month);

-- Enable Row Level Security
ALTER TABLE public.budgets ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can view their own budgets"
    ON public.budgets FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own budgets"
    ON public.budgets FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own budgets"
    ON public.budgets FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own budgets"
    ON public.budgets FOR DELETE
    USING (auth.uid() = user_id);

-- Grant permissions
GRANT ALL ON public.budgets TO authenticated;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';