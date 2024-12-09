-- Add tag-related columns to transactions table
ALTER TABLE public.transactions
ADD COLUMN tag_category_id UUID REFERENCES public.tag_categories(id),
ADD COLUMN tag_id UUID REFERENCES public.tags(id);

-- Add indexes for new columns
CREATE INDEX idx_transactions_tag_category ON public.transactions(tag_category_id);
CREATE INDEX idx_transactions_tag ON public.transactions(tag_id);

-- Add constraint to ensure tag_id belongs to tag_category_id
ALTER TABLE public.transactions
ADD CONSTRAINT valid_tag CHECK (
    (tag_id IS NULL AND tag_category_id IS NULL) OR
    (tag_id IS NOT NULL AND tag_category_id IS NOT NULL AND
     EXISTS (
         SELECT 1 FROM public.tags
         WHERE id = tag_id AND category_id = tag_category_id
     ))
);

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';