-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their own transactions" ON public.transactions;
DROP POLICY IF EXISTS "Users can insert their own transactions" ON public.transactions;
DROP POLICY IF EXISTS "Users can update their own transactions" ON public.transactions;

-- Create new RLS policies with proper security context
CREATE POLICY "Users can view their own transactions"
    ON public.transactions 
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own transactions"
    ON public.transactions 
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own transactions"
    ON public.transactions 
    FOR UPDATE
    USING (auth.uid() = user_id);

-- Ensure RLS is enabled
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Grant proper permissions to authenticated users
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON public.transactions TO authenticated;

-- Force refresh of schema cache
NOTIFY pgrst, 'reload schema';