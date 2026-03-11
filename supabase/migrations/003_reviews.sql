-- =====================================================
-- 003 – Table des avis produits (reviews)
-- =====================================================

CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(product_id, user_id)
);

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Tout le monde peut lire les avis
CREATE POLICY "Anyone can read reviews"
  ON public.reviews FOR SELECT
  USING (true);

-- Les utilisateurs authentifiés peuvent créer leur propre avis
CREATE POLICY "Users can insert own review"
  ON public.reviews FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Les utilisateurs peuvent modifier leur propre avis
CREATE POLICY "Users can update own review"
  ON public.reviews FOR UPDATE
  USING (auth.uid() = user_id);

-- Les utilisateurs peuvent supprimer leur propre avis
CREATE POLICY "Users can delete own review"
  ON public.reviews FOR DELETE
  USING (auth.uid() = user_id);

-- Index pour accélérer les requêtes
CREATE INDEX idx_reviews_product ON public.reviews(product_id);
CREATE INDEX idx_reviews_user ON public.reviews(user_id);
