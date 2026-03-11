-- Activer Realtime sur les tables catalogue : produits, sections, bannières, publicités.
-- Les changements (INSERT/UPDATE/DELETE) seront diffusés en temps réel aux clients.
-- Permet d'afficher automatiquement les nouveaux contenus sans redémarrer l'app.
-- En cas d'erreur "already member of publication", ignorer (table déjà activée).

ALTER PUBLICATION supabase_realtime ADD TABLE public.products;
ALTER PUBLICATION supabase_realtime ADD TABLE public.product_sections;
ALTER PUBLICATION supabase_realtime ADD TABLE public.banners;
ALTER PUBLICATION supabase_realtime ADD TABLE public.publicites;
