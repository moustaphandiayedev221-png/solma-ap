-- Activer Realtime sur la table orders pour que l'admin reçoive les nouvelles commandes en temps réel.
-- Si erreur "already member", ignorer (table déjà dans la publication).
ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
