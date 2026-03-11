-- Colways Admin - RLS pour les utilisateurs admin
-- Créer la table admin_users et ajouter ton user_id après première connexion :
--   INSERT INTO public.admin_users (user_id) VALUES ('uuid-de-ton-user');
-- Puis se reconnecter dans l'app admin pour avoir les droits CRUD.

CREATE TABLE IF NOT EXISTS public.admin_users (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can read admin_users"
  ON public.admin_users FOR SELECT
  USING (auth.uid() = user_id);

-- Seul un super-admin (ou service_role) peut insérer dans admin_users.
-- Ici on permet à tout utilisateur authentifié d'insérer (pour bootstrap).
-- En prod, exécuter l'INSERT manuellement depuis le SQL Editor.
CREATE POLICY "Allow insert admin_users for bootstrap"
  ON public.admin_users FOR INSERT
  WITH CHECK (true);

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean AS $$
  SELECT EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid());
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Catégories : lecture pour tous, CRUD pour admin
CREATE POLICY "Admin can insert categories"
  ON public.categories FOR INSERT
  WITH CHECK (public.is_admin());

CREATE POLICY "Admin can update categories"
  ON public.categories FOR UPDATE
  USING (public.is_admin());

CREATE POLICY "Admin can delete categories"
  ON public.categories FOR DELETE
  USING (public.is_admin());

-- Produits : CRUD pour admin
CREATE POLICY "Admin can insert products"
  ON public.products FOR INSERT
  WITH CHECK (public.is_admin());

CREATE POLICY "Admin can update products"
  ON public.products FOR UPDATE
  USING (public.is_admin());

CREATE POLICY "Admin can delete products"
  ON public.products FOR DELETE
  USING (public.is_admin());

-- Commandes : admin peut tout lire et mettre à jour le statut
CREATE POLICY "Admin can read all orders"
  ON public.orders FOR SELECT
  USING (public.is_admin());

CREATE POLICY "Admin can update orders"
  ON public.orders FOR UPDATE
  USING (public.is_admin());

-- Order_items : admin peut lire (pour afficher les commandes)
CREATE POLICY "Admin can read all order_items"
  ON public.order_items FOR SELECT
  USING (public.is_admin());

-- Profiles : admin peut lire tous les profils
CREATE POLICY "Admin can read all profiles"
  ON public.profiles FOR SELECT
  USING (public.is_admin());
