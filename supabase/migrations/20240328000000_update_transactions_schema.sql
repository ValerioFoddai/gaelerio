-- Drop existing tables if they exist
DROP TABLE IF EXISTS public.transactions_tags CASCADE;
DROP TABLE IF EXISTS public.transactions CASCADE;

-- Create transactions table with subcategory and tag support
CREATE TABLE public.transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    date TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    description TEXT,
    amount DECIMAL(10,2) NOT NULL,
    expense_category_id UUID NOT NULL REFERENCES public.expense_main_categories(id),
    expense_subcategory_id UUID REFERENCES public.expense_subcategories(id),
    tag_category_id UUID REFERENCES public.tag_categories(id),
    tag_id UUID REFERENCES public.tags(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Basic constraints
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at),
    CONSTRAINT valid_tag CHECK (
        (tag_id IS NULL AND tag_category_id IS NULL) OR
        (tag_id IS NOT NULL AND tag_category_id IS NOT NULL AND
         EXISTS (
             SELECT 1 FROM public.tags
             WHERE id = tag_id AND category_id = tag_category_id
         ))
    )
);

-- Create function to validate subcategory
CREATE OR REPLACE FUNCTION validate_transaction_subcategory()
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
CREATE TRIGGER validate_transaction_subcategory
    BEFORE INSERT OR UPDATE ON public.transactions
    FOR EACH ROW
    EXECUTE FUNCTION validate_transaction_subcategory();

-- Create indexes
CREATE INDEX idx_transactions_user ON public.transactions(user_id);
CREATE INDEX idx_transactions_category ON public.transactions(expense_category_id);
CREATE INDEX idx_transactions_subcategory ON public.transactions(expense_subcategory_id);
CREATE INDEX idx_transactions_tag_category ON public.transactions(tag_category_id);
CREATE INDEX idx_transactions_tag ON public.transactions(tag_id);
CREATE INDEX idx_transactions_date ON public.transactions(date);

-- Enable Row Level Security
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies for transactions
CREATE POLICY "Users can view their own transactions"
    ON public.transactions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own transactions"
    ON public.transactions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own transactions"
    ON public.transactions FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own transactions"
    ON public.transactions FOR DELETE
    USING (auth.uid() = user_id);

-- Grant permissions
GRANT ALL ON public.transactions TO authenticated;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';