-- Associer chaque publicité à une section produit (popular, tenues-africaines, sacs-a-main, sports)
-- Une publicité n'est affichée que dans sa section, et seulement si cette section a des produits.

ALTER TABLE public.publicites
ADD COLUMN IF NOT EXISTS section TEXT DEFAULT 'popular';

-- Index pour filtrer par section
CREATE INDEX IF NOT EXISTS idx_publicites_section ON public.publicites (section, is_active, sort_order);

-- Mettre à jour les lignes existantes sans section
UPDATE public.publicites SET section = 'popular' WHERE section IS NULL;
