-- Sections Tenues Africaines et Sacs à Main
-- Les produits avec section='tenues-africaines' ou section='sacs-a-main' s'afficheront dans ces sections sur la home.

-- Ajout de la catégorie Tenues Africaines (pour filtre par catégorie si besoin)
INSERT INTO public.categories (name, slug, sort_order) VALUES
  ('Tenues Africaines', 'tenues-africaines', 10)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  sort_order = EXCLUDED.sort_order;

-- Ajout de la catégorie Sacs à Main (pour filtre par catégorie si besoin)
INSERT INTO public.categories (name, slug, sort_order) VALUES
  ('Sacs à Main', 'sacs-a-main', 11)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  sort_order = EXCLUDED.sort_order;
