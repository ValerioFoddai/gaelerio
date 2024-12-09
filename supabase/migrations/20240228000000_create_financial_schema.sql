-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "citext";

-- Create enum types for various statuses and categories
CREATE TYPE transaction_status AS ENUM ('pending', 'completed', 'failed', 'cancelled', 'refunded');
CREATE TYPE transaction_type AS ENUM ('deposit', 'withdrawal', 'transfer', 'payment', 'refund', 'fee', 'interest');
CREATE TYPE payment_method_type AS ENUM ('bank_transfer', 'credit_card', 'debit_card', 'cash', 'crypto', 'other');
CREATE TYPE account_type AS ENUM ('checking', 'savings', 'investment', 'credit', 'wallet');
CREATE TYPE currency_code AS ENUM ('USD', 'EUR', 'GBP', 'JPY', 'CHF', 'CAD', 'AUD');

-- Create accounts table
CREATE TABLE public.accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    account_type account_type NOT NULL,
    account_name TEXT NOT NULL,
    account_number TEXT,
    currency currency_code NOT NULL DEFAULT 'USD',
    current_balance DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    available_balance DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    CONSTRAINT valid_balance CHECK (current_balance >= -999999999999.99 AND current_balance <= 999999999999.99),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Create transaction categories table
CREATE TABLE public.transaction_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id), -- NULL for system categories
    name TEXT NOT NULL,
    description TEXT,
    parent_id UUID REFERENCES public.transaction_categories(id),
    icon TEXT,
    color TEXT,
    is_system BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Create payment methods table
CREATE TABLE public.payment_methods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    method_type payment_method_type NOT NULL,
    name TEXT NOT NULL,
    last_four TEXT,
    expiry_date DATE,
    is_default BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Create transactions table
CREATE TABLE public.transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    account_id UUID NOT NULL REFERENCES public.accounts(id),
    category_id UUID REFERENCES public.transaction_categories(id),
    payment_method_id UUID REFERENCES public.payment_methods(id),
    transaction_type transaction_type NOT NULL,
    status transaction_status NOT NULL DEFAULT 'pending',
    amount DECIMAL(15,2) NOT NULL,
    currency currency_code NOT NULL,
    description TEXT,
    reference_number TEXT,
    transaction_date TIMESTAMP WITH TIME ZONE NOT NULL,
    settled_date TIMESTAMP WITH TIME ZONE,
    meta JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    CONSTRAINT valid_amount CHECK (amount != 0),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at),
    CONSTRAINT valid_settled_date CHECK (settled_date IS NULL OR settled_date >= transaction_date)
);

-- Create transaction attachments table
CREATE TABLE public.transaction_attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_id UUID NOT NULL REFERENCES public.transactions(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    file_type TEXT NOT NULL,
    file_size INTEGER NOT NULL,
    file_url TEXT NOT NULL,
    uploaded_by UUID NOT NULL REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    CONSTRAINT valid_file_size CHECK (file_size > 0)
);

-- Create transaction tags table (for many-to-many relationship)
CREATE TABLE public.transaction_tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    name TEXT NOT NULL,
    color TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at),
    UNIQUE(user_id, name)
);

-- Create transaction_tags_mapping table
CREATE TABLE public.transaction_tags_mapping (
    transaction_id UUID REFERENCES public.transactions(id) ON DELETE CASCADE,
    tag_id UUID REFERENCES public.transaction_tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    PRIMARY KEY (transaction_id, tag_id)
);

-- Create recurring transactions table
CREATE TABLE public.recurring_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    account_id UUID NOT NULL REFERENCES public.accounts(id),
    category_id UUID REFERENCES public.transaction_categories(id),
    transaction_type transaction_type NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    currency currency_code NOT NULL,
    description TEXT,
    frequency TEXT NOT NULL, -- Cron expression
    start_date DATE NOT NULL,
    end_date DATE,
    last_executed_at TIMESTAMP WITH TIME ZONE,
    next_execution_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    CONSTRAINT valid_amount CHECK (amount != 0),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at),
    CONSTRAINT valid_date_range CHECK (end_date IS NULL OR end_date >= start_date)
);

-- Create indexes for better query performance
CREATE INDEX idx_transactions_user_id ON public.transactions(user_id);
CREATE INDEX idx_transactions_account_id ON public.transactions(account_id);
CREATE INDEX idx_transactions_category_id ON public.transactions(category_id);
CREATE INDEX idx_transactions_transaction_date ON public.transactions(transaction_date);
CREATE INDEX idx_transactions_status ON public.transactions(status);
CREATE INDEX idx_transactions_type ON public.transactions(transaction_type);

CREATE INDEX idx_accounts_user_id ON public.accounts(user_id);
CREATE INDEX idx_accounts_account_type ON public.accounts(account_type);

CREATE INDEX idx_transaction_categories_user_id ON public.transaction_categories(user_id);
CREATE INDEX idx_transaction_categories_parent_id ON public.transaction_categories(parent_id);

CREATE INDEX idx_payment_methods_user_id ON public.payment_methods(user_id);
CREATE INDEX idx_payment_methods_type ON public.payment_methods(method_type);

CREATE INDEX idx_recurring_transactions_user_id ON public.recurring_transactions(user_id);
CREATE INDEX idx_recurring_transactions_next_execution ON public.recurring_transactions(next_execution_at);

-- Enable Row Level Security
ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaction_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaction_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaction_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaction_tags_mapping ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recurring_transactions ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can view their own accounts"
    ON public.accounts FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can view their own transactions"
    ON public.transactions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can view their own categories"
    ON public.transaction_categories FOR SELECT
    USING (auth.uid() = user_id OR is_system = true);

CREATE POLICY "Users can view their own payment methods"
    ON public.payment_methods FOR SELECT
    USING (auth.uid() = user_id);

-- Create functions for handling timestamps
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create triggers for updated_at
CREATE TRIGGER set_updated_at_accounts
    BEFORE UPDATE ON public.accounts
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_transactions
    BEFORE UPDATE ON public.transactions
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_categories
    BEFORE UPDATE ON public.transaction_categories
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_payment_methods
    BEFORE UPDATE ON public.payment_methods
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_recurring_transactions
    BEFORE UPDATE ON public.recurring_transactions
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO postgres, anon, authenticated, service_role;

-- Refresh schema cache
NOTIFY pgrst, 'reload schema';