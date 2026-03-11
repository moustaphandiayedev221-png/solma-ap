-- Seuls les utilisateurs peuvent s'ajouter eux-mêmes dans admin_users
-- (lors de l'inscription depuis l'app admin)
DROP POLICY IF EXISTS "Allow insert admin_users for bootstrap" ON public.admin_users;
CREATE POLICY "Users can add themselves as admin"
  ON public.admin_users FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());
