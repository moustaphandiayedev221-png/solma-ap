-- Mise à jour des link_url des bannières pour une navigation ciblée
-- (chaque bannière redirige vers une page spécifique, pas "tous les produits")

UPDATE public.banners
SET link_url = '/products/section/popular'
WHERE title ILIKE '%meilleure vente%' OR title ILIKE '%best sale%' OR title ILIKE '%réduction%';

UPDATE public.banners
SET link_url = '/nouveautes'
WHERE title ILIKE '%nouvelle collection%' OR title ILIKE '%new collection%'
   OR title ILIKE '%exclusivité%' OR title ILIKE '%exclusive%'
   OR title ILIKE '%édition limitée%';

UPDATE public.banners
SET link_url = '/help-center'
WHERE title ILIKE '%livraison gratuite%' OR title ILIKE '%free shipping%';
