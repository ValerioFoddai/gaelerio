-- Drop existing tables if they exist
DROP TABLE IF EXISTS public.transaction_tags CASCADE;
DROP TABLE IF EXISTS public.tags CASCADE;

-- Create tags table
CREATE TABLE public.tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    CONSTRAINT unique_tag_name_per_user UNIQUE (user_id, name),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Create transaction_tags table
CREATE TABLE public.transaction_tags (
    transaction_id UUID NOT NULL REFERENCES public.transactions(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES public.tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    PRIMARY KEY (transaction_id, tag_id)
);

-- Create indexes
CREATE INDEX idx_tags_user ON public.tags(user_id);
CREATE INDEX idx_transaction_tags_transaction ON public.transaction_tags(transaction_id);
CREATE INDEX idx_transaction_tags_tag ON public.transaction_tags(tag_id);

-- Enable Row Level Security
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaction_tags ENABLE ROW LEVEL SECURITY;

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

-- Grant permissions
GRANT ALL ON public.tags TO authenticated;
GRANT ALL ON public.transaction_tags TO authenticated;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';