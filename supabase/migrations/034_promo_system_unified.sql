-- =====================================================
-- 034 – Système de codes promo type Amazon (100% fonctionnel)
-- =====================================================
-- Unifie le schéma promotions, ajoute limite par utilisateur,
-- et crée la RPC increment_promo_uses.

-- 1. Colonnes manquantes sur promotions (compatibilité 001 vs 004)
ALTER TABLE public.promotions ADD COLUMN IF NOT EXISTS min_order_amount DECIMAL(12,2) DEFAULT 0;
ALTER TABLE public.promotions ADD COLUMN IF NOT EXISTS starts_at TIMESTAMPTZ;
ALTER TABLE public.promotions ADD COLUMN IF NOT EXISTS expires_at TIMESTAMPTZ;
ALTER TABLE public.promotions ADD COLUMN IF NOT EXISTS current_uses INTEGER DEFAULT 0;
ALTER TABLE public.promotions ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;
ALTER TABLE public.promotions ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE public.promotions ADD COLUMN IF NOT EXISTS max_uses_per_user INTEGER;

-- 2. Migration des données depuis ancien schéma (001)
DO $$
BEGIN
  -- Supprimer la contrainte AVANT de modifier discount_type (elle n'autorise que 'percent','fixed')
  ALTER TABLE public.promotions DROP CONSTRAINT IF EXISTS promotions_discount_type_check;
  ALTER TABLE public.promotions DROP CONSTRAINT IF EXISTS promotions_discount_type_check1;
  -- Ajouter la nouvelle contrainte (accepte percentage, percent, fixed)
  ALTER TABLE public.promotions ADD CONSTRAINT promotions_discount_type_check
    CHECK (discount_type IN ('percentage', 'percent', 'fixed'));

  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='promotions' AND column_name='min_order') THEN
    UPDATE public.promotions SET min_order_amount = COALESCE(min_order_amount, min_order, 0) WHERE min_order_amount = 0 AND min_order IS NOT NULL;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='promotions' AND column_name='valid_from') THEN
    UPDATE public.promotions SET starts_at = COALESCE(starts_at, valid_from) WHERE starts_at IS NULL AND valid_from IS NOT NULL;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='promotions' AND column_name='valid_until') THEN
    UPDATE public.promotions SET expires_at = COALESCE(expires_at, valid_until) WHERE expires_at IS NULL AND valid_until IS NOT NULL;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='promotions' AND column_name='used_count') THEN
    UPDATE public.promotions SET current_uses = COALESCE(current_uses, used_count) WHERE current_uses = 0 AND used_count IS NOT NULL;
  END IF;
  UPDATE public.promotions SET discount_type = 'percentage' WHERE discount_type = 'percent';
END $$;

-- 3. Début / fin par défaut si NULL
UPDATE public.promotions SET starts_at = created_at WHERE starts_at IS NULL AND created_at IS NOT NULL;

-- 4. Table des usages par utilisateur (limite type Amazon)
CREATE TABLE IF NOT EXISTS public.promotion_usages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  promotion_id UUID NOT NULL REFERENCES public.promotions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_promotion_usages_promo_user ON public.promotion_usages(promotion_id, user_id);

ALTER TABLE public.promotion_usages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own promotion usages"
  ON public.promotion_usages FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own promotion usages"
  ON public.promotion_usages FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admin can read promotion usages"
  ON public.promotion_usages FOR SELECT
  USING (public.is_admin());

-- 5. RPC pour incrémenter les usages (atomique)
CREATE OR REPLACE FUNCTION public.increment_promo_uses(
  p_promo_id UUID,
  p_user_id UUID,
  p_order_id UUID DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_max_per_user INT;
  v_uses_by_user INT;
BEGIN
  SELECT max_uses_per_user INTO v_max_per_user FROM public.promotions WHERE id = p_promo_id;
  v_max_per_user := COALESCE(v_max_per_user, 0);

  IF v_max_per_user > 0 THEN
    SELECT COUNT(*)::INT INTO v_uses_by_user
    FROM public.promotion_usages
    WHERE promotion_id = p_promo_id AND user_id = p_user_id;

    IF v_uses_by_user >= v_max_per_user THEN
      RAISE EXCEPTION 'PROMO_MAX_USES_PER_USER';
    END IF;
  END IF;

  INSERT INTO public.promotion_usages (promotion_id, user_id, order_id)
  VALUES (p_promo_id, p_user_id, p_order_id);

  UPDATE public.promotions
  SET current_uses = COALESCE(current_uses, 0) + 1
  WHERE id = p_promo_id;
END;
$$;
