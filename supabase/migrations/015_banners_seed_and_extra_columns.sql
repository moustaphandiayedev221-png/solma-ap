-- Colonnes supplémentaires pour les bannières (watermark, tagline, accent_color, shoe_angle)
ALTER TABLE public.banners
  ADD COLUMN IF NOT EXISTS watermark TEXT,
  ADD COLUMN IF NOT EXISTS tagline TEXT,
  ADD COLUMN IF NOT EXISTS accent_color TEXT,
  ADD COLUMN IF NOT EXISTS shoe_angle REAL DEFAULT -0.25;

-- Seed des bannières existantes (données migrées depuis le code)
-- Insertion uniquement si la table est vide (évite doublons en cas de ré-exécution)
DO $$
BEGIN
  IF (SELECT COUNT(*) FROM public.banners) = 0 THEN
    INSERT INTO public.banners (
  title,
  subtitle,
  image_url,
  link_url,
  accent_text,
  accent_value,
  cta_text,
  gradient_start,
  gradient_end,
  watermark,
  tagline,
  accent_color,
  shoe_angle,
  sort_order,
  is_active
) VALUES
  (
    'Meilleure vente',
    'Réduction',
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
    NULL,
    'Jusqu''à ',
    '60%',
    'Acheter',
    '#1E3A5F',
    '#0D253F',
    'GOOD',
    'COMFORT',
    '#D4956A',
    -0.25,
    0,
    true
  ),
  (
    'Nouvelle collection',
    'Printemps 2026',
    'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?w=400',
    NULL,
    '',
    '2026',
    'Explorer',
    '#2D6A4F',
    '#1B4332',
    'NEW',
    'STYLE',
    '#95D5B2',
    -0.20,
    1,
    true
  ),
  (
    'Livraison gratuite',
    'Sur toutes les commandes',
    'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=400',
    NULL,
    'Dès ',
    '$50',
    'Commander',
    '#6A040F',
    '#370617',
    'FREE',
    'PREMIUM',
    '#F48C06',
    -0.30,
    2,
    true
  ),
  (
    'Exclusivité',
    'Édition limitée',
    'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=400',
    NULL,
    'Uniquement sur ',
    'Colways',
    'Découvrir',
    '#3A0CA3',
    '#240046',
    'LTD',
    'LUXE',
    '#C77DFF',
    -0.18,
    3,
    true
  );
  END IF;
END $$;
