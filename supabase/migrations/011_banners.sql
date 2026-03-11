-- ========== BANNIÈRES (gérées par l'admin, affichées dans l'app Colways) ==========
CREATE TABLE IF NOT EXISTS public.banners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  subtitle TEXT,
  image_url TEXT NOT NULL,
  link_url TEXT,
  accent_text TEXT,
  accent_value TEXT,
  cta_text TEXT DEFAULT 'Shop Now',
  gradient_start TEXT,
  gradient_end TEXT,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_banners_sort ON public.banners (sort_order, is_active);

ALTER TABLE public.banners ENABLE ROW LEVEL SECURITY;

-- Lecture par tous (app mobile) - uniquement bannières actives
CREATE POLICY "Banners are readable by everyone when active"
  ON public.banners FOR SELECT
  USING (is_active = true);

-- CRUD pour admin
CREATE POLICY "Admin can insert banners"
  ON public.banners FOR INSERT
  WITH CHECK (public.is_admin());

CREATE POLICY "Admin can update banners"
  ON public.banners FOR UPDATE
  USING (public.is_admin());

CREATE POLICY "Admin can delete banners"
  ON public.banners FOR DELETE
  USING (public.is_admin());

CREATE POLICY "Admin can read all banners"
  ON public.banners FOR SELECT
  USING (public.is_admin());
