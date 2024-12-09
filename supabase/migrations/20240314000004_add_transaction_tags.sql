```sql
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
CREATE INDEX idx_transaction_tags_transaction ON public.transaction_tags(transaction_id);
CREATE INDEX idx_transaction_tags_tag ON public.transaction_tags(tag_id);

-- Enable Row Level Security
ALTER TABLE public.transaction_tags ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
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

-- Grant permissions
GRANT ALL ON public.transaction_tags TO authenticated;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';
```