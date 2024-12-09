-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create transaction_categories table
CREATE TABLE public.transaction_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id), -- NULL for system categories
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_id UUID REFERENCES public.transaction_categories(id),
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_system BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Constraints
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at),
    CONSTRAINT unique_category_name_per_user UNIQUE NULLS NOT DISTINCT (user_id, name),
    CONSTRAINT valid_parent_category CHECK (
        -- Parent category must be a system category or owned by the same user
        parent_id IS NULL OR
        (
            parent_id IN (
                SELECT id FROM public.transaction_categories 
                WHERE is_system = true OR user_id = transaction_categories.user_id
            )
        )
    )
);

-- Add category_id to transactions table
ALTER TABLE public.transactions
ADD COLUMN category_id UUID REFERENCES public.transaction_categories(id);

-- Create indexes
CREATE INDEX idx_transaction_categories_user_id ON public.transaction_categories(user_id);
CREATE INDEX idx_transaction_categories_parent_id ON public.transaction_categories(parent_id);
CREATE INDEX idx_transaction_categories_is_active ON public.transaction_categories(is_active);
CREATE INDEX idx_transactions_category_id ON public.transactions(category_id);

-- Enable RLS
ALTER TABLE public.transaction_categories ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can view system categories and their own categories"
    ON public.transaction_categories FOR SELECT
    USING (
        is_system = true OR
        auth.uid() = user_id
    );

CREATE POLICY "Users can insert their own categories"
    ON public.transaction_categories FOR INSERT
    WITH CHECK (
        auth.uid() = user_id AND
        NOT is_system -- Users cannot create system categories
    );

CREATE POLICY "Users can update their own categories"
    ON public.transaction_categories FOR UPDATE
    USING (
        auth.uid() = user_id AND
        NOT is_system -- Users cannot update system categories
    );

CREATE POLICY "Users can delete their own categories"
    ON public.transaction_categories FOR DELETE
    USING (
        auth.uid() = user_id AND
        NOT is_system -- Users cannot delete system categories
    );

-- Create function to handle updated_at
CREATE OR REPLACE FUNCTION public.handle_categories_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for updated_at
CREATE TRIGGER set_categories_updated_at
    BEFORE UPDATE ON public.transaction_categories
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_categories_updated_at();

-- Insert default system categories
INSERT INTO public.transaction_categories (name, description, is_system, is_active) VALUES
    ('Income', 'All types of income', true, true),
    ('Expenses', 'All types of expenses', true, true),
    ('Transfers', 'Money transfers between accounts', true, true);

-- Insert default income subcategories
INSERT INTO public.transaction_categories (name, description, parent_id, is_system, is_active)
SELECT 
    name,
    description,
    (SELECT id FROM public.transaction_categories WHERE name = 'Income' AND is_system = true),
    true,
    true
FROM (VALUES
    ('Salary', 'Regular employment income'),
    ('Freelance', 'Income from freelance work'),
    ('Investments', 'Income from investments'),
    ('Gifts', 'Money received as gifts'),
    ('Other Income', 'Other types of income')
) AS categories(name, description);

-- Insert default expense subcategories
INSERT INTO public.transaction_categories (name, description, parent_id, is_system, is_active)
SELECT 
    name,
    description,
    (SELECT id FROM public.transaction_categories WHERE name = 'Expenses' AND is_system = true),
    true,
    true
FROM (VALUES
    ('Housing', 'Rent, mortgage, and housing expenses'),
    ('Transportation', 'Car, public transport, and travel expenses'),
    ('Food', 'Groceries and dining out'),
    ('Utilities', 'Electricity, water, internet, etc.'),
    ('Healthcare', 'Medical expenses and insurance'),
    ('Entertainment', 'Movies, games, and hobbies'),
    ('Shopping', 'Clothing and personal items'),
    ('Education', 'Courses, books, and training'),
    ('Other Expenses', 'Miscellaneous expenses')
) AS categories(name, description);

-- Grant permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON public.transaction_categories TO authenticated;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';