-- Premier admin : permet à un utilisateur authentifié de s'inscrire comme admin
-- UNIQUEMENT si la table admin_users est vide (aucun admin existant).
-- Sinon, l'ajout se fait manuellement via SQL Editor.

DROP POLICY IF EXISTS "Allow insert admin_users for bootstrap" ON public.admin_users;

CREATE POLICY "First admin can self-register"
  ON public.admin_users FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL
    AND (SELECT COUNT(*) FROM public.admin_users) = 0
  );
