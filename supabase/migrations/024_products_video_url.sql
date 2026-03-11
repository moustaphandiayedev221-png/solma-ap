-- Vidéo illustrative du produit (optionnelle, affichée après les images dans le carrousel)
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS video_url TEXT;
