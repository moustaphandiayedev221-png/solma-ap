-- ============================================================
-- Vérifier les admins et le stockage vidéo
-- Exécuter dans Supabase SQL Editor
-- ============================================================

-- 1. Lister tous les utilisateurs et leur statut admin
SELECT 
  u.id, 
  u.email, 
  CASE WHEN a.user_id IS NOT NULL THEN 'OUI' ELSE 'NON' END as est_admin
FROM auth.users u
LEFT JOIN public.admin_users a ON a.user_id = u.id
ORDER BY u.email;

-- 2. Pour ajouter un admin, remplacer VOTRE_EMAIL@exemple.com :
-- INSERT INTO public.admin_users (user_id)
-- SELECT id FROM auth.users WHERE email = 'VOTRE_EMAIL@exemple.com'
-- ON CONFLICT (user_id) DO NOTHING;

-- 3. Vérifier que le bucket product-videos existe
SELECT id, name, public FROM storage.buckets WHERE id = 'product-videos';
