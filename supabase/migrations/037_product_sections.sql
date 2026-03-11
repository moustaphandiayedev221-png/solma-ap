-- Table pour les sections produit : nom affiché et ordre configurables par l'admin.
-- La clé technique (key) reste fixe pour la cohérence avec products.section et publicites.section.

CREATE TABLE IF NOT EXISTS public.product_sections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Index pour tri par ordre
CREATE INDEX IF NOT EXISTS idx_product_sections_display_order ON public.product_sections (display_order);

-- RLS : lecture publique (client app), écriture admin uniquement
ALTER TABLE public.product_sections ENABLE ROW LEVEL SECURITY;

-- Lecture pour tous (y compris anon)
CREATE POLICY "product_sections_select" ON public.product_sections
  FOR SELECT USING (true);

-- Insert/Update/Delete pour admins
CREATE POLICY "product_sections_admin_all" ON public.product_sections
  FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Seed des sections par défaut (clés fixes = popular, tenues-africaines, sacs-a-main, sports)
INSERT INTO public.product_sections (key, display_name, display_order) VALUES
  ('popular', 'Populaire', 0),
  ('tenues-africaines', 'Tenues Africaines', 1),
  ('sacs-a-main', 'Sacs à Main', 2),
  ('sports', 'Sport', 3)
ON CONFLICT (key) DO NOTHING;
