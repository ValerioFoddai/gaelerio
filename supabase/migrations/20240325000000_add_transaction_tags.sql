-- Drop existing tables if they exist
DROP TABLE IF EXISTS public.transactions_tags CASCADE;
DROP TABLE IF EXISTS public.transactions CASCADE;

-- Create transactions table
CREATE TABLE public.transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    date TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    description TEXT,
    amount DECIMAL(10,2) NOT NULL,
    expense_category_id UUID NOT NULL REFERENCES public.expense_main_categories(id),
    expense_subcategory_id UUID REFERENCES public.expense_subcategories(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Constraints
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at),
    CONSTRAINT valid_subcategory CHECK (
        expense_subcategory_id IS NULL OR
        EXISTS (
            SELECT 1 FROM public.expense_subcategories
            WHERE id = expense_subcategory_id
            AND main_category_id = expense_category_id
        )
    )
);

-- Create transactions_tags junction table
CREATE TABLE public.transactions_tags (
    transaction_id UUID NOT NULL REFERENCES public.transactions(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES public.tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    PRIMARY KEY (transaction_id, tag_id)
);

-- Create indexes
CREATE INDEX idx_transactions_user ON public.transactions(user_id);
CREATE INDEX idx_transactions_category ON public.transactions(expense_category_id);
CREATE INDEX idx_transactions_subcategory ON public.transactions(expense_subcategory_id);
CREATE INDEX idx_transactions_date ON public.transactions(date);
CREATE INDEX idx_transactions_tags_transaction ON public.transactions_tags(transaction_id);
CREATE INDEX idx_transactions_tags_tag ON public.transactions_tags(tag_id);

-- Enable Row Level Security
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions_tags ENABLE ROW LEVEL SECURITY;

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

-- Create RLS Policies for transactions_tags
CREATE POLICY "Users can view tags for their transactions"
    ON public.transactions_tags FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.transactions
            WHERE id = transaction_id
            AND user_id = auth.uid()
        )
    );

CREATE POLICY "Users can manage tags for their transactions"
    ON public.transactions_tags
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.transactions
            WHERE id = transaction_id
            AND user_id = auth.uid()
        )
    );

-- Grant permissions
GRANT ALL ON public.transactions TO authenticated;
GRANT ALL ON public.transactions_tags TO authenticated;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';