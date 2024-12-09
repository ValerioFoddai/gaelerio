-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create expense_categories table
CREATE TABLE public.expense_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id), -- NULL for system categories
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN ('Essentials', 'Lifestyle', 'Financial_Obligations', 'Family_Social', 'Miscellaneous', 'Optional')),
    description TEXT,
    parent_id UUID REFERENCES public.expense_categories(id),
    icon TEXT,
    color TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_system BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Constraints
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at),
    CONSTRAINT unique_category_name_per_user UNIQUE NULLS NOT DISTINCT (user_id, name)
);

-- Create indexes
CREATE INDEX idx_expense_categories_user_id ON public.expense_categories(user_id);
CREATE INDEX idx_expense_categories_parent_id ON public.expense_categories(parent_id);
CREATE INDEX idx_expense_categories_type ON public.expense_categories(type);
CREATE INDEX idx_expense_categories_is_active ON public.expense_categories(is_active);

-- Enable RLS
ALTER TABLE public.expense_categories ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can view system categories and their own categories"
    ON public.expense_categories FOR SELECT
    USING (
        is_system = true OR
        auth.uid() = user_id
    );

CREATE POLICY "Users can insert their own categories"
    ON public.expense_categories FOR INSERT
    WITH CHECK (
        auth.uid() = user_id AND
        NOT is_system -- Users cannot create system categories
    );

CREATE POLICY "Users can update their own categories"
    ON public.expense_categories FOR UPDATE
    USING (
        auth.uid() = user_id AND
        NOT is_system -- Users cannot update system categories
    );

CREATE POLICY "Users can delete their own categories"
    ON public.expense_categories FOR DELETE
    USING (
        auth.uid() = user_id AND
        NOT is_system -- Users cannot delete system categories
    );

-- Create function to handle updated_at
CREATE OR REPLACE FUNCTION public.handle_expense_categories_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for updated_at
CREATE TRIGGER set_expense_categories_updated_at
    BEFORE UPDATE ON public.expense_categories
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_expense_categories_updated_at();

-- Insert default system categories
INSERT INTO public.expense_categories (name, type, description, is_system, is_active) VALUES
    ('Housing', 'Essentials', 'Housing and accommodation expenses', true, true),
    ('Food & Groceries', 'Essentials', 'Food and grocery expenses', true, true),
    ('Transportation', 'Essentials', 'Transportation and travel expenses', true, true),
    ('Health & Wellness', 'Essentials', 'Healthcare and medical expenses', true, true),
    ('Utilities', 'Essentials', 'Utility bills and services', true, true),
    ('Entertainment', 'Lifestyle', 'Entertainment and recreation', true, true),
    ('Shopping', 'Lifestyle', 'Shopping and retail expenses', true, true),
    ('Dining Out', 'Lifestyle', 'Restaurant and dining expenses', true, true),
    ('Travel', 'Lifestyle', 'Travel and vacation expenses', true, true),
    ('Education', 'Lifestyle', 'Education and learning expenses', true, true),
    ('Debt Repayments', 'Financial_Obligations', 'Debt and loan payments', true, true),
    ('Savings', 'Financial_Obligations', 'Savings and investments', true, true),
    ('Investments', 'Financial_Obligations', 'Investment expenses', true, true),
    ('Children', 'Family_Social', 'Children-related expenses', true, true),
    ('Gifts', 'Family_Social', 'Gifts and presents', true, true),
    ('Charity', 'Family_Social', 'Charitable donations', true, true),
    ('Personal Care', 'Miscellaneous', 'Personal care and wellness', true, true),
    ('Pets', 'Miscellaneous', 'Pet-related expenses', true, true),
    ('Subscriptions', 'Miscellaneous', 'Subscription services', true, true),
    ('Emergencies', 'Miscellaneous', 'Emergency expenses', true, true),
    ('Professional', 'Optional', 'Professional and business expenses', true, true),
    ('Home Improvement', 'Optional', 'Home improvement and repairs', true, true),
    ('Insurance', 'Optional', 'Insurance premiums', true, true),
    ('Taxes', 'Optional', 'Tax payments', true, true);

-- Grant permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON public.expense_categories TO authenticated;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';