```sql
-- Drop existing tables if they exist
DROP TABLE IF EXISTS public.transaction_tags CASCADE;
DROP TABLE IF EXISTS public.transactions CASCADE;

-- Create transactions table with category support
CREATE TABLE public.transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    category_id UUID NOT NULL REFERENCES public.expense_main_categories(id),
    subcategory_id UUID REFERENCES public.expense_subcategories(id),
    amount DECIMAL(10,2) NOT NULL,
    description TEXT,
    date TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Constraints
    CONSTRAINT valid_amount CHECK (amount != 0),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Create transaction_tags table
CREATE TABLE public.transaction_tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_id UUID NOT NULL REFERENCES public.transactions(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES public.tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Ensure each tag is only used once per transaction
    UNIQUE(transaction_id, tag_id)
);

-- Create indexes
CREATE INDEX idx_transactions_user ON public.transactions(user_id);
CREATE INDEX idx_transactions_category ON public.transactions(category_id);
CREATE INDEX idx_transactions_subcategory ON public.transactions(subcategory_id);
CREATE INDEX idx_transactions_date ON public.transactions(date);
CREATE INDEX idx_transaction_tags_transaction ON public.transaction_tags(transaction_id);
CREATE INDEX idx_transaction_tags_tag ON public.transaction_tags(tag_id);

-- Enable Row Level Security
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaction_tags ENABLE ROW LEVEL SECURITY;

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

-- Create RLS Policies for transaction_tags
CREATE POLICY "Users can view tags for their transactions"
    ON public.transaction_tags FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.transactions
            WHERE id = transaction_id
            AND user_id = auth.uid()
        )
    );

CREATE POLICY "Users can add tags to their transactions"
    ON public.transaction_tags FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.transactions
            WHERE id = transaction_id
            AND user_id = auth.uid()
        )
    );

CREATE POLICY "Users can remove tags from their transactions"
    ON public.transaction_tags FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.transactions
            WHERE id = transaction_id
            AND user_id = auth.uid()
        )
    );

-- Create function to validate subcategory
CREATE OR REPLACE FUNCTION validate_transaction_subcategory()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.subcategory_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.expense_subcategories
            WHERE id = NEW.subcategory_id
            AND main_category_id = NEW.category_id
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

-- Grant permissions
GRANT ALL ON public.transactions TO authenticated;
GRANT ALL ON public.transaction_tags TO authenticated;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';
```