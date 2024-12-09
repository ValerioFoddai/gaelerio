-- Drop existing constraint and columns
ALTER TABLE public.transactions 
DROP CONSTRAINT IF EXISTS valid_tag;

ALTER TABLE public.transactions
DROP COLUMN IF EXISTS tag_category_id,
DROP COLUMN IF EXISTS tag_id;

-- Re-add columns without the constraint
ALTER TABLE public.transactions
ADD COLUMN tag_category_id UUID REFERENCES public.tag_categories(id),
ADD COLUMN tag_id UUID REFERENCES public.tags(id);

-- Add indexes for new columns
CREATE INDEX idx_transactions_tag_category ON public.transactions(tag_category_id);
CREATE INDEX idx_transactions_tag ON public.transactions(tag_id);

-- Create function to validate tag relationship
CREATE OR REPLACE FUNCTION validate_transaction_tag()
RETURNS TRIGGER AS $$
BEGIN
    -- If either tag_id or tag_category_id is NULL, both must be NULL
    IF (NEW.tag_id IS NULL AND NEW.tag_category_id IS NOT NULL) OR
       (NEW.tag_id IS NOT NULL AND NEW.tag_category_id IS NULL) THEN
        RAISE EXCEPTION 'Both tag_id and tag_category_id must be either NULL or non-NULL';
    END IF;

    -- If both are non-NULL, validate the relationship
    IF NEW.tag_id IS NOT NULL AND NEW.tag_category_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.tags
            WHERE id = NEW.tag_id AND category_id = NEW.tag_category_id
        ) THEN
            RAISE EXCEPTION 'Tag must belong to the specified category';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for tag validation
CREATE TRIGGER validate_transaction_tag
    BEFORE INSERT OR UPDATE ON public.transactions
    FOR EACH ROW
    EXECUTE FUNCTION validate_transaction_tag();

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';