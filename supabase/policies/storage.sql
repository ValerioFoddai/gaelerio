-- Enable RLS on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Remove existing policies if any
DROP POLICY IF EXISTS "Avatar images are publicly accessible" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own avatar" ON storage.objects;

-- Create storage policies
CREATE POLICY "Avatar images are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
    AND owner = auth.uid()
    AND (
        CASE 
            WHEN name ~ '^[^/]+/[^/]+$' THEN
                split_part(name, '/', 1) = auth.uid()::text
            ELSE false
        END
    )
);

CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
    AND owner = auth.uid()
    AND (
        CASE 
            WHEN name ~ '^[^/]+/[^/]+$' THEN
                split_part(name, '/', 1) = auth.uid()::text
            ELSE false
        END
    )
);

CREATE POLICY "Users can delete their own avatar"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
    AND owner = auth.uid()
    AND (
        CASE 
            WHEN name ~ '^[^/]+/[^/]+$' THEN
                split_part(name, '/', 1) = auth.uid()::text
            ELSE false
        END
    )
);