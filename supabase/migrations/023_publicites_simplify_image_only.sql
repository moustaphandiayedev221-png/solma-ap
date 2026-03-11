-- Simplification de la table publicites : uniquement les champs liés aux images
-- Suppression de title, price, label (non utilisés pour l'affichage image seule)

ALTER TABLE public.publicites DROP COLUMN IF EXISTS title;
ALTER TABLE public.publicites DROP COLUMN IF EXISTS price;
ALTER TABLE public.publicites DROP COLUMN IF EXISTS label;
