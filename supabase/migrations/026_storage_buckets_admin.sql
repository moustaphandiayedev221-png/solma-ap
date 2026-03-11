-- Buckets pour bannières et publicités (upload admin depuis galerie)
-- Les admins peuvent uploader, lecture publique pour l'app client

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'banners',
  'banners',
  true,
  5242880,
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'publicites',
  'publicites',
  true,
  5242880,
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- RLS pour bucket banners
DROP POLICY IF EXISTS "Admins can insert banners" ON storage.objects;
DROP POLICY IF EXISTS "Admins can update banners" ON storage.objects;
DROP POLICY IF EXISTS "Admins can delete banners" ON storage.objects;
DROP POLICY IF EXISTS "Public can read banners" ON storage.objects;

CREATE POLICY "Admins can insert banners"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'banners' AND public.is_admin());

CREATE POLICY "Admins can update banners"
  ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'banners' AND public.is_admin())
  WITH CHECK (bucket_id = 'banners' AND public.is_admin());

CREATE POLICY "Admins can delete banners"
  ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'banners' AND public.is_admin());

CREATE POLICY "Public can read banners"
  ON storage.objects FOR SELECT USING (bucket_id = 'banners');

-- RLS pour bucket publicites
DROP POLICY IF EXISTS "Admins can insert publicites" ON storage.objects;
DROP POLICY IF EXISTS "Admins can update publicites" ON storage.objects;
DROP POLICY IF EXISTS "Admins can delete publicites" ON storage.objects;
DROP POLICY IF EXISTS "Public can read publicites" ON storage.objects;

CREATE POLICY "Admins can insert publicites"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'publicites' AND public.is_admin());

CREATE POLICY "Admins can update publicites"
  ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'publicites' AND public.is_admin())
  WITH CHECK (bucket_id = 'publicites' AND public.is_admin());

CREATE POLICY "Admins can delete publicites"
  ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'publicites' AND public.is_admin());

CREATE POLICY "Public can read publicites"
  ON storage.objects FOR SELECT USING (bucket_id = 'publicites');
