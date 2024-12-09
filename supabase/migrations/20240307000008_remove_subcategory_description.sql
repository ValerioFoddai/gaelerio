-- Drop and recreate the subcategories table without description
DROP TABLE IF EXISTS public.expense_subcategories CASCADE;

CREATE TABLE public.expense_subcategories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    main_category_id UUID NOT NULL REFERENCES public.expense_main_categories(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    name_it VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Constraints
    CONSTRAINT unique_subcategory_name_per_main UNIQUE (main_category_id, name),
    CONSTRAINT proper_updated_at CHECK (updated_at >= created_at)
);

-- Create indexes
CREATE INDEX idx_expense_subcategories_main_category ON public.expense_subcategories(main_category_id);

-- Insert subcategories with translations
DO $$
DECLARE
    bills_id UUID;
BEGIN
    -- Get Bills & Utilities category ID
    SELECT id INTO bills_id
    FROM public.expense_main_categories 
    WHERE name = 'Bills & Utilities';

    -- Insert Bills & Utilities subcategories
    INSERT INTO public.expense_subcategories (main_category_id, name, name_it)
    VALUES
        (bills_id, 'Electricity', 'Luce'),
        (bills_id, 'Garbage', 'Spazzatura'),
        (bills_id, 'Gas', 'Gas'),
        (bills_id, 'Internet', 'Internet'),
        (bills_id, 'Phone', 'Telefono'),
        (bills_id, 'Water', 'Acqua');
END $$;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';