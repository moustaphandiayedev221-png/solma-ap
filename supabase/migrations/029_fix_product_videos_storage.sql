-- Correctif : politiques RLS pour upload vidéos produits
-- Si l'erreur "row-level security policy" persiste, exécuter insert_admin_user.sql

-- S'assurer que le bucket existe
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'product-videos',
  'product-videos',
  true,
  52428800,
  ARRAY['video/mp4', 'video/webm', 'video/quicktime', 'video/x-m4v']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Supprimer et recréer les politiques
DROP POLICY IF EXISTS "Admins can insert product-videos" ON storage.objects;
DROP POLICY IF EXISTS "Admins can update product-videos" ON storage.objects;
DROP POLICY IF EXISTS "Admins can delete product-videos" ON storage.objects;
DROP POLICY IF EXISTS "Public can read product-videos" ON storage.objects;

-- INSERT : admins uniquement
CREATE POLICY "Admins can insert product-videos"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'product-videos'
    AND public.is_admin()
  );

CREATE POLICY "Admins can update product-videos"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'product-videos' AND public.is_admin())
  WITH CHECK (bucket_id = 'product-videos' AND public.is_admin());

CREATE POLICY "Admins can delete product-videos"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'product-videos' AND public.is_admin());

CREATE POLICY "Public can read product-videos"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'product-videos');
