-- Colonne is_new pour les produits : permet la redirection bannière "nouveautés" vers /products/section/new
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS is_new BOOLEAN DEFAULT false;

CREATE INDEX IF NOT EXISTS idx_products_is_new ON public.products (is_new) WHERE is_new = true;
