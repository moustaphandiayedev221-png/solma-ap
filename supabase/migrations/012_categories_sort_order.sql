-- Ajouter sort_order aux catégories si absent
ALTER TABLE public.categories
  ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;
