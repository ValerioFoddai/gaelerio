-- Drop existing tables if they exist
DROP TABLE IF EXISTS public.transaction_tags CASCADE;
DROP TABLE IF EXISTS public.tags CASCADE;
DROP TABLE IF EXISTS public.tag_categories CASCADE;

-- Create tag categories table
CREATE TABLE public.tag_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    CONSTRAINT unique_category_name_per_user UNIQUE (user_id, name),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Create tags table
CREATE TABLE public.tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES public.tag_categories(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id),
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    CONSTRAINT unique_tag_name_per_category UNIQUE (category_id, name),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Create transaction_tags junction table
CREATE TABLE public.transaction_tags (
    transaction_id UUID NOT NULL REFERENCES public.transactions(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES public.tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    PRIMARY KEY (transaction_id, tag_id)
);

-- Create indexes
CREATE INDEX idx_tag_categories_user ON public.tag_categories(user_id);
CREATE INDEX idx_tags_category ON public.tags(category_id);
CREATE INDEX idx_tags_user ON public.tags(user_id);
CREATE INDEX idx_transaction_tags_transaction ON public.transaction_tags(transaction_id);
CREATE INDEX idx_transaction_tags_tag ON public.transaction_tags(tag_id);

-- Enable Row Level Security
ALTER TABLE public.tag_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaction_tags ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies for tag categories
CREATE POLICY "Users can view their own tag categories"
    ON public.tag_categories FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own tag categories"
    ON public.tag_categories FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own tag categories"
    ON public.tag_categories FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own tag categories"
    ON public.tag_categories FOR DELETE
    USING (auth.uid() = user_id);

-- Create RLS Policies for tags
CREATE POLICY "Users can view their own tags"
    ON public.tags FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own tags"
    ON public.tags FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own tags"
    ON public.tags FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own tags"
    ON public.tags FOR DELETE
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

CREATE POLICY "Users can manage tags for their transactions"
    ON public.transaction_tags
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.transactions
            WHERE id = transaction_id
            AND user_id = auth.uid()
        )
    );

-- Create function to validate transaction tags
CREATE OR REPLACE FUNCTION validate_transaction_tag()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM public.tags t
        JOIN public.transactions tr ON tr.user_id = t.user_id
        WHERE t.id = NEW.tag_id
        AND tr.id = NEW.transaction_id
    ) THEN
        RAISE EXCEPTION 'Tag must belong to the same user as the transaction';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for tag validation
CREATE TRIGGER validate_transaction_tag
    BEFORE INSERT OR UPDATE ON public.transaction_tags
    FOR EACH ROW
    EXECUTE FUNCTION validate_transaction_tag();

-- Grant permissions
GRANT ALL ON public.tag_categories TO authenticated;
GRANT ALL ON public.tags TO authenticated;
GRANT ALL ON public.transaction_tags TO authenticated;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';