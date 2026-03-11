-- ========== NOUVEAUTÉS (contenu publicitaire géré par l'admin) ==========
-- Les nouveautés s'affichent dans la section "Nouveautés" de l'app (page d'accueil).
-- Chaque entrée : titre, prix, image, label optionnel (ex: "MEILLEUR CHOIX"), lien vers produit ou URL.
CREATE TABLE IF NOT EXISTS public.nouveautes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  price DECIMAL(12, 2) NOT NULL,
  image_url TEXT NOT NULL,
  label TEXT,  -- ex: "MEILLEUR CHOIX", "NOUVEAU", etc.
  product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,  -- lien vers un produit existant
  link_url TEXT,  -- URL de redirection (si pas de product_id)
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_nouveautes_sort ON public.nouveautes (sort_order, is_active);

ALTER TABLE public.nouveautes ENABLE ROW LEVEL SECURITY;

-- Lecture par tous (app mobile) - uniquement nouveautés actives
CREATE POLICY "Nouveautes are readable by everyone when active"
  ON public.nouveautes FOR SELECT
  USING (is_active = true);

-- CRUD pour admin
CREATE POLICY "Admin can insert nouveautes"
  ON public.nouveautes FOR INSERT
  WITH CHECK (public.is_admin());

CREATE POLICY "Admin can update nouveautes"
  ON public.nouveautes FOR UPDATE
  USING (public.is_admin());

CREATE POLICY "Admin can delete nouveautes"
  ON public.nouveautes FOR DELETE
  USING (public.is_admin());

CREATE POLICY "Admin can read all nouveautes"
  ON public.nouveautes FOR SELECT
  USING (public.is_admin());
