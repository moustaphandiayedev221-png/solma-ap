-- =====================================================
-- 005 – Table de suivi des commandes (order_tracking)
-- =====================================================

CREATE TABLE IF NOT EXISTS public.order_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  status TEXT NOT NULL,
  description TEXT,
  location TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.order_tracking ENABLE ROW LEVEL SECURITY;

-- Les utilisateurs peuvent lire le tracking de leurs propres commandes
CREATE POLICY "Users can read tracking of own orders"
  ON public.order_tracking FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_tracking.order_id
        AND orders.user_id = auth.uid()
    )
  );

-- Les admins peuvent gérer tout le tracking
CREATE POLICY "Admin can manage tracking"
  ON public.order_tracking FOR ALL
  USING (public.is_admin());

-- Index pour accélérer les requêtes
CREATE INDEX idx_tracking_order ON public.order_tracking(order_id);

-- Trigger : auto-créer un événement tracking à la création d'une commande
CREATE OR REPLACE FUNCTION public.handle_new_order_tracking()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.order_tracking (order_id, status, description)
  VALUES (NEW.id, NEW.status, 'Commande créée');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_order_created
  AFTER INSERT ON public.orders
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_order_tracking();
