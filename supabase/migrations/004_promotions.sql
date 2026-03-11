-- =====================================================
-- 004 – Table des promotions / codes promo
-- =====================================================

CREATE TABLE IF NOT EXISTS public.promotions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  description TEXT,
  discount_type TEXT NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
  discount_value DECIMAL(12,2) NOT NULL CHECK (discount_value > 0),
  min_order_amount DECIMAL(12,2) DEFAULT 0,
  max_uses INTEGER,
  current_uses INTEGER DEFAULT 0,
  starts_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.promotions ENABLE ROW LEVEL SECURITY;

-- Les utilisateurs authentifiés peuvent lire les promotions actives
CREATE POLICY "Authenticated users can read promotions"
  ON public.promotions FOR SELECT
  USING (auth.role() = 'authenticated');

-- Les admins peuvent gérer toutes les promotions
CREATE POLICY "Admin can manage promotions"
  ON public.promotions FOR ALL
  USING (public.is_admin());

-- Ajout des colonnes promo sur la table orders
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS promo_code TEXT;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS discount_amount DECIMAL(12,2) DEFAULT 0;

-- Colonne manquante si la table a été créée par une version antérieure
ALTER TABLE public.promotions ADD COLUMN IF NOT EXISTS description TEXT;

-- Données de test
INSERT INTO public.promotions (code, description, discount_type, discount_value, min_order_amount, max_uses, expires_at)
VALUES
  ('WELCOME10', 'Bienvenue : -10%', 'percentage', 10, 30, 100, NOW() + INTERVAL '1 year'),
  ('COLWAYS20', 'Colways VIP : -20€', 'fixed', 20, 50, 50, NOW() + INTERVAL '6 months');
