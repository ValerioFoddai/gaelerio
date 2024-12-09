-- Drop transaction-related tables and functions
DROP TABLE IF EXISTS public.transaction_tags CASCADE;
DROP TABLE IF EXISTS public.transactions CASCADE;
DROP FUNCTION IF EXISTS validate_transaction_subcategory() CASCADE;
DROP FUNCTION IF EXISTS validate_transaction_tag() CASCADE;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';