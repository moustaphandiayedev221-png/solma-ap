-- ========== USER_NOTIFICATION_PREFERENCES (préférences persistées) ==========
CREATE TABLE IF NOT EXISTS public.user_notification_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  push_enabled BOOLEAN DEFAULT true,
  promo_enabled BOOLEAN DEFAULT false,
  quiet_hours_start TEXT,  -- ex: "22:00" (format HH:mm)
  quiet_hours_end TEXT,    -- ex: "08:00"
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);

CREATE INDEX IF NOT EXISTS idx_user_notification_prefs_user ON public.user_notification_preferences (user_id);

ALTER TABLE public.user_notification_preferences ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own notification preferences" ON public.user_notification_preferences;
CREATE POLICY "Users can manage own notification preferences"
  ON public.user_notification_preferences FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admin can read preferences for targeting" ON public.user_notification_preferences;
CREATE POLICY "Admin can read preferences for targeting"
  ON public.user_notification_preferences FOR SELECT
  USING (public.is_admin());

-- ========== Enrichir notifications (colonnes optionnelles pour payload riche) ==========
-- deep_link, image_url, category, priority, scheduled_at, expires_at déjà supportés via data JSONB
-- On ajoute des colonnes explicites pour requêtes et index

ALTER TABLE public.notifications
  ADD COLUMN IF NOT EXISTS category TEXT,  -- order, promo, system, order_shipped, order_delivered, cart_abandonment
  ADD COLUMN IF NOT EXISTS priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
  ADD COLUMN IF NOT EXISTS image_url TEXT,
  ADD COLUMN IF NOT EXISTS deep_link TEXT,
  ADD COLUMN IF NOT EXISTS scheduled_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS expires_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_notifications_category ON public.notifications (category);
CREATE INDEX IF NOT EXISTS idx_notifications_scheduled ON public.notifications (scheduled_at) WHERE scheduled_at IS NOT NULL;

-- ========== NOTIFICATION_TEMPLATES (admin) ==========
-- Vérifier si la table existe avant insert (migration idempotente)
CREATE TABLE IF NOT EXISTS public.notification_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  title_template TEXT NOT NULL,
  body_template TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'system',
  deep_link_template TEXT,  -- ex: /order/{{order_id}}
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.notification_templates ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admin can manage notification templates" ON public.notification_templates;
CREATE POLICY "Admin can manage notification templates"
  ON public.notification_templates FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Seed templates de base (insert si vide)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.notification_templates LIMIT 1) THEN
    INSERT INTO public.notification_templates (name, title_template, body_template, category, deep_link_template)
    VALUES
      ('Commande expédiée', 'Votre commande est expédiée 🚚', 'Votre commande #{{order_short_id}} est en route. Suivez la livraison dans l''app.', 'order_shipped', '/orders'),
      ('Commande livrée', 'Votre commande est arrivée ✅', 'Votre colis a été livré. Merci pour votre achat !', 'order_delivered', '/orders'),
      ('Promo flash', 'Offre exclusive -{{percent}}% ⚡', '{{message}} Valable jusqu''à {{expiry}}. Utilisez le code {{code}}.', 'promo', '/publicites'),
      ('Panier abandonné', 'Vous avez oublié quelque chose 🛒', 'Des articles vous attendent dans votre panier. Complétez votre achat !', 'cart_abandonment', '/main?tab=3'),
      ('Annonce système', '{{title}}', '{{body}}', 'system', null);
  END IF;
END $$;
