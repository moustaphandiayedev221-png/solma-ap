-- Utilisateur peut insérer une notification qui le cible (confirmation de commande).
DROP POLICY IF EXISTS "Users can insert own order notification" ON public.notifications;
CREATE POLICY "Users can insert own order notification"
  ON public.notifications FOR INSERT
  WITH CHECK (
    target_type = 'user'
    AND target_user_id = auth.uid()
  );
