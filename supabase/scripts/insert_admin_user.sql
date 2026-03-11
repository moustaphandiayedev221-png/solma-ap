-- ============================================================
-- Cas particulier : ajouter un admin manuellement
-- Normalement, l'inscription depuis l'app admin ajoute
-- automatiquement l'utilisateur dans admin_users.
-- Ce script sert uniquement pour des comptes existants créés
-- avant cette fonctionnalité.
-- ============================================================
-- Remplacer VOTRE_EMAIL@exemple.com puis exécuter dans SQL Editor
-- ============================================================

INSERT INTO public.admin_users (user_id)
SELECT id FROM auth.users WHERE email = 'VOTRE_EMAIL@exemple.com'
ON CONFLICT (user_id) DO NOTHING;
