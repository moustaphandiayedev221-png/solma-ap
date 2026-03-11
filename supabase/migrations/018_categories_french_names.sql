-- Libellés français pour les catégories (affichage UI)
-- Les slugs (men, women, kids) restent inchangés pour le filtrage des produits.

UPDATE public.categories SET name = 'Hommes' WHERE slug = 'men';
UPDATE public.categories SET name = 'Femmes' WHERE slug = 'women';
UPDATE public.categories SET name = 'Enfants' WHERE slug = 'kids';
