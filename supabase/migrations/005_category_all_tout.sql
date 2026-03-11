-- Colways - Catégorie "Tout" pour la première chip (libellé depuis la table categories)
-- Le texte "Tout" ne doit pas être en dur : il vient de cette ligne.
-- À exécuter dans Supabase SQL Editor.

INSERT INTO public.categories (name, slug) VALUES
  ('Tout', 'all')
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name;
