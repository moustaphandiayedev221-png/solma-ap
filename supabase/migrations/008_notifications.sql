-- ========== NOTIFICATIONS (envoyées depuis l'admin, reçues par l'app Colways) ==========
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB DEFAULT '{}',
  target_type TEXT NOT NULL CHECK (target_type IN ('all', 'user')),
  target_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_target ON public.notifications (target_type, target_user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications (created_at DESC);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own notifications" ON public.notifications;
CREATE POLICY "Users can read own notifications"
  ON public.notifications FOR SELECT
  USING (
    target_type = 'all'
    OR target_user_id = auth.uid()
  );

DROP POLICY IF EXISTS "Admin can insert notifications" ON public.notifications;
CREATE POLICY "Admin can insert notifications"
  ON public.notifications FOR INSERT
  WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admin can read all notifications" ON public.notifications;
CREATE POLICY "Admin can read all notifications"
  ON public.notifications FOR SELECT
  USING (public.is_admin());

-- ========== NOTIFICATION_READS (lu / non lu par utilisateur) ==========
CREATE TABLE IF NOT EXISTS public.notification_reads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  notification_id UUID NOT NULL REFERENCES public.notifications(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  read_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(notification_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_notification_reads_user ON public.notification_reads (user_id);

ALTER TABLE public.notification_reads ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own notification_reads" ON public.notification_reads;
CREATE POLICY "Users can manage own notification_reads"
  ON public.notification_reads FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ========== USER_FCM_TOKENS (pour push en arrière-plan) ==========
CREATE TABLE IF NOT EXISTS public.user_fcm_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  platform TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, platform)
);

CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_user ON public.user_fcm_tokens (user_id);

ALTER TABLE public.user_fcm_tokens ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own fcm tokens" ON public.user_fcm_tokens;
CREATE POLICY "Users can manage own fcm tokens"
  ON public.user_fcm_tokens FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admin can read fcm tokens for push" ON public.user_fcm_tokens;
CREATE POLICY "Admin can read fcm tokens for push"
  ON public.user_fcm_tokens FOR SELECT
  USING (public.is_admin());

-- Activer Realtime sur notifications (pour mise à jour en temps réel dans l'app)
-- À exécuter une fois : Dashboard > Database > Replication > supabase_realtime > ajouter la table notifications
-- ou en SQL (peut échouer si déjà ajoutée) :
-- ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
