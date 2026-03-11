-- Vérifier que les produits ont bien un category_id et que les catégories existent
-- Exécuter dans Supabase SQL Editor pour diagnostiquer une page catégorie vide

-- 1. Catégories existantes (men, women, kids)
SELECT id, name, slug FROM public.categories WHERE slug IN ('men', 'women', 'kids', 'hommes', 'femmes', 'enfants');

-- 2. Nombre de produits par catégorie
SELECT c.slug, c.name, COUNT(p.id) as product_count
FROM public.categories c
LEFT JOIN public.products p ON p.category_id = c.id
WHERE c.slug IN ('men', 'women', 'kids')
GROUP BY c.id, c.slug, c.name;

-- 3. Produits sans catégorie (category_id NULL)
SELECT COUNT(*) as products_without_category FROM public.products WHERE category_id IS NULL;
