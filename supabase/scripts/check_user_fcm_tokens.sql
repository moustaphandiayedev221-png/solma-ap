-- ============================================================
-- Vérifier les tokens FCM des clients (user_fcm_tokens)
-- Exécuter dans Supabase SQL Editor
-- ============================================================

-- 1. Lister tous les tokens client avec l'email de l'utilisateur
SELECT 
  t.id,
  t.user_id,
  u.email,
  t.platform,
  LEFT(t.token, 50) || '...' as token_preview,
  t.updated_at
FROM public.user_fcm_tokens t
LEFT JOIN auth.users u ON u.id = t.user_id
ORDER BY t.updated_at DESC;

-- 2. Nombre de tokens par utilisateur
SELECT 
  u.email,
  COUNT(t.id) as nb_tokens,
  STRING_AGG(t.platform, ', ') as platforms
FROM auth.users u
LEFT JOIN public.user_fcm_tokens t ON t.user_id = u.id
GROUP BY u.id, u.email
ORDER BY nb_tokens DESC;

-- 3. Lister les tokens admin (admin_fcm_tokens)
SELECT 
  t.id,
  t.user_id,
  u.email,
  t.platform,
  LEFT(t.token, 50) || '...' as token_preview,
  t.updated_at
FROM public.admin_fcm_tokens t
LEFT JOIN auth.users u ON u.id = t.user_id
ORDER BY t.updated_at DESC;
