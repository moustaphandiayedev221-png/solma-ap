-- Bucket product-images pour les images produits et bannières
-- Permet aux admins d'uploader, lecture publique pour afficher les images
-- Exécuter dans Supabase SQL Editor

-- Créer le bucket (ignore si déjà existant)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'product-images',
  'product-images',
  true,
  5242880,
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Supprimer les anciennes policies si elles existent (pour ré-exécution)
DROP POLICY IF EXISTS "Admins can insert product-images" ON storage.objects;
DROP POLICY IF EXISTS "Admins can update product-images" ON storage.objects;
DROP POLICY IF EXISTS "Admins can delete product-images" ON storage.objects;
DROP POLICY IF EXISTS "Public can read product-images" ON storage.objects;

-- RLS sur storage.objects : les admins peuvent tout faire sur product-images
CREATE POLICY "Admins can insert product-images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'product-images'
    AND public.is_admin()
  );

CREATE POLICY "Admins can update product-images"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'product-images'
    AND public.is_admin()
  )
  WITH CHECK (
    bucket_id = 'product-images'
    AND public.is_admin()
  );

CREATE POLICY "Admins can delete product-images"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'product-images'
    AND public.is_admin()
  );

-- Lecture publique (bucket public, mais on explicite pour SELECT si besoin)
CREATE POLICY "Public can read product-images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'product-images');
