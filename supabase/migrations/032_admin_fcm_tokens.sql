-- Table pour les tokens FCM des admins (notifications nouvelles commandes)
-- Permet d'envoyer des push en 1er plan ET arrière-plan
CREATE TABLE IF NOT EXISTS public.admin_fcm_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  platform TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, platform)
);

CREATE INDEX IF NOT EXISTS idx_admin_fcm_tokens_user ON public.admin_fcm_tokens (user_id);

ALTER TABLE public.admin_fcm_tokens ENABLE ROW LEVEL SECURITY;

-- Seuls les admins peuvent enregistrer leur token
DROP POLICY IF EXISTS "Admins can insert own token" ON public.admin_fcm_tokens;
CREATE POLICY "Admins can insert own token"
  ON public.admin_fcm_tokens FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id AND public.is_admin());

DROP POLICY IF EXISTS "Admins can update own token" ON public.admin_fcm_tokens;
CREATE POLICY "Admins can update own token"
  ON public.admin_fcm_tokens FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admins can delete own token" ON public.admin_fcm_tokens;
CREATE POLICY "Admins can delete own token"
  ON public.admin_fcm_tokens FOR DELETE
  USING (auth.uid() = user_id);
