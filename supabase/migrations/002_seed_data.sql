-- Colways - Données de test avec vraies images (Unsplash)
-- Exécuter après 001_initial_schema.sql dans Supabase SQL Editor

-- ========== PRODUITS POPULAR (section popular) ==========
INSERT INTO public.products (
  category_id,
  name,
  slug,
  description,
  price,
  compare_at_price,
  image_urls,
  sizes,
  colors,
  stock,
  is_featured,
  section
) VALUES
(
  (SELECT id FROM public.categories WHERE slug = 'men' LIMIT 1),
  'Air Jordan 1 Retro High',
  'air-jordan-1-retro-high',
  'Iconic silhouette with premium leather and Air cushioning. A streetwear essential for style on and off the court.',
  121.00,
  145.00,
  ARRAY[
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
    'https://images.unsplash.com/photo-1556906781-9a412961c28c?w=600',
    'https://images.unsplash.com/photo-1608236647042-f2d6c44958b2?w=600'
  ],
  ARRAY['36','38','40','42','44','46'],
  '[{"name":"Noir","hex":"#1A1A1A"},{"name":"Blanc","hex":"#F5F5F5"},{"name":"Rouge","hex":"#E53935"}]'::jsonb,
  50,
  true,
  'popular'
),
(
  (SELECT id FROM public.categories WHERE slug = 'men' LIMIT 1),
  'Nike Vomero 17',
  'nike-vomero-17',
  'Plush cushioning and responsive ride. Engineered for all-day comfort and smooth transitions.',
  196.00,
  220.00,
  ARRAY[
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
    'https://images.unsplash.com/photo-1556906781-9a412961c28c?w=600'
  ],
  ARRAY['38','40','42','44','46'],
  '[{"name":"Blanc","hex":"#FFFFFF"},{"name":"Vert","hex":"#2E7D32"}]'::jsonb,
  30,
  true,
  'popular'
),
(
  (SELECT id FROM public.categories WHERE slug = 'men' LIMIT 1),
  'Nike Dunk Low',
  'nike-dunk-low',
  'Classic basketball design reimagined. Versatile and timeless for everyday wear.',
  115.00,
  130.00,
  ARRAY[
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
    'https://images.unsplash.com/photo-1560769629-975bc94dc1f4?w=600'
  ],
  ARRAY['36','38','40','42','44'],
  '[{"name":"Noir","hex":"#1A1A1A"},{"name":"Blanc","hex":"#FFFFFF"}]'::jsonb,
  45,
  true,
  'popular'
),
(
  (SELECT id FROM public.categories WHERE slug = 'men' LIMIT 1),
  'Air Max 90',
  'air-max-90',
  'Visible Air cushioning and durable design. A running icon since 1990.',
  140.00,
  160.00,
  ARRAY[
    'https://images.unsplash.com/photo-1600185365923-5a2580148e4a?w=600',
    'https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?w=600'
  ],
  ARRAY['38','40','42','44','46'],
  '[{"name":"Gris","hex":"#616161"},{"name":"Blanc","hex":"#FFFFFF"}]'::jsonb,
  35,
  true,
  'popular'
),
(
  (SELECT id FROM public.categories WHERE slug = 'women' LIMIT 1),
  'Nike Blazer Mid',
  'nike-blazer-mid',
  'Clean lines and premium materials. The perfect blend of heritage and modern style.',
  95.00,
  110.00,
  ARRAY[
    'https://images.unsplash.com/photo-1595950653107-6e8c2c2b3b3b?w=600'
  ],
  ARRAY['36','38','40','42'],
  '[{"name":"Blanc","hex":"#FFFFFF"},{"name":"Noir","hex":"#1A1A1A"}]'::jsonb,
  40,
  true,
  'popular'
),
(
  (SELECT id FROM public.categories WHERE slug = 'men' LIMIT 1),
  'Nike Pegasus 40',
  'nike-pegasus-40',
  'Responsive foam and secure fit. Built for runners who demand comfort and performance.',
  130.00,
  150.00,
  ARRAY[
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600'
  ],
  ARRAY['40','42','44','46'],
  '[{"name":"Bleu","hex":"#1565C0"},{"name":"Noir","hex":"#1A1A1A"}]'::jsonb,
  25,
  true,
  'popular'
)
ON CONFLICT (slug) DO NOTHING;

-- ========== PRODUITS SPORTS (section sports) ==========
INSERT INTO public.products (
  category_id,
  name,
  slug,
  description,
  price,
  compare_at_price,
  image_urls,
  sizes,
  colors,
  stock,
  is_featured,
  section
) VALUES
(
  (SELECT id FROM public.categories WHERE slug = 'men' LIMIT 1),
  'Nike Zoom Fly 5',
  'nike-zoom-fly-5',
  'Lightweight racing shoe with ZoomX foam. For runners chasing their next PR.',
  160.00,
  180.00,
  ARRAY[
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
    'https://images.unsplash.com/photo-1556906781-9a412961c28c?w=600'
  ],
  ARRAY['40','42','44','46'],
  '[{"name":"Orange","hex":"#EF6C00"},{"name":"Noir","hex":"#1A1A1A"}]'::jsonb,
  20,
  false,
  'sports'
),
(
  (SELECT id FROM public.categories WHERE slug = 'men' LIMIT 1),
  'Nike Vaporfly 3',
  'nike-vaporfly-3',
  'Next-generation racing technology. Carbon plate and ZoomX for maximum energy return.',
  250.00,
  275.00,
  ARRAY[
    'https://images.unsplash.com/photo-1556906781-9a412961c28c?w=600',
    'https://images.unsplash.com/photo-1608236647042-f2d6c44958b2?w=600'
  ],
  ARRAY['40','42','44','46'],
  '[{"name":"Rouge","hex":"#C62828"},{"name":"Blanc","hex":"#FFFFFF"}]'::jsonb,
  15,
  false,
  'sports'
),
(
  (SELECT id FROM public.categories WHERE slug = 'men' LIMIT 1),
  'Nike Invincible Run 3',
  'nike-invincible-run-3',
  'Maximum cushioning for recovery runs. ZoomX foam from heel to toe.',
  180.00,
  200.00,
  ARRAY[
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600'
  ],
  ARRAY['40','42','44','46'],
  '[{"name":"Bleu","hex":"#0D47A1"},{"name":"Blanc","hex":"#FFFFFF"}]'::jsonb,
  22,
  false,
  'sports'
),
(
  (SELECT id FROM public.categories WHERE slug = 'men' LIMIT 1),
  'Nike Alphafly 2',
  'nike-alphafly-2',
  'Elite racing shoe with dual Zoom Air pods. Designed for marathon champions.',
  275.00,
  300.00,
  ARRAY[
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
    'https://images.unsplash.com/photo-1560769629-975bc94dc1f4?w=600'
  ],
  ARRAY['40','42','44','46'],
  '[{"name":"Vert","hex":"#1B5E20"},{"name":"Noir","hex":"#1A1A1A"}]'::jsonb,
  12,
  false,
  'sports'
),
(
  (SELECT id FROM public.categories WHERE slug = 'women' LIMIT 1),
  'Nike Tempo Next%',
  'nike-tempo-next',
  'Responsive tempo training shoe. Combines speed and cushioning for daily workouts.',
  170.00,
  190.00,
  ARRAY[
    'https://images.unsplash.com/photo-1600185365923-5a2580148e4a?w=600',
    'https://images.unsplash.com/photo-1595950653107-6e8c2c2b3b3b?w=600'
  ],
  ARRAY['36','38','40','42'],
  '[{"name":"Rose","hex":"#AD1457"},{"name":"Blanc","hex":"#FFFFFF"}]'::jsonb,
  18,
  false,
  'sports'
),
(
  (SELECT id FROM public.categories WHERE slug = 'men' LIMIT 1),
  'Nike Structure 24',
  'nike-structure-24',
  'Stable support for overpronators. Engineered for a smooth, supported ride.',
  140.00,
  160.00,
  ARRAY[
    'https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?w=600',
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600'
  ],
  ARRAY['40','42','44','46'],
  '[{"name":"Gris","hex":"#424242"},{"name":"Noir","hex":"#1A1A1A"}]'::jsonb,
  28,
  false,
  'sports'
)
ON CONFLICT (slug) DO NOTHING;

-- ========== PRODUIT DÉTAIL EXEMPLE (Jordan 4 style) pour page produit ==========
INSERT INTO public.products (
  category_id,
  name,
  slug,
  description,
  price,
  compare_at_price,
  image_urls,
  sizes,
  colors,
  stock,
  is_featured,
  section
) VALUES
(
  (SELECT id FROM public.categories WHERE slug = 'men' LIMIT 1),
  'Nike Men''s Jordan Air 4 Retro',
  'nike-jordan-air-4-retro',
  'Where heritage meets modern comfort. The Nike Men''s Jordan Air 4 Retro delivers legendary style, responsive Air cushioning, and durable construction crafted for those who live the game on and off the court.',
  195.00,
  220.00,
  ARRAY[
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
    'https://images.unsplash.com/photo-1556906781-9a412961c28c?w=600',
    'https://images.unsplash.com/photo-1608236647042-f2d6c44958b2?w=600',
    'https://images.unsplash.com/photo-1560769629-975bc94dc1f4?w=600'
  ],
  ARRAY['34','36','38','40','42','44','46'],
  '[{"name":"Noir","hex":"#1A1A1A"},{"name":"Blanc","hex":"#FFFFFF"},{"name":"Bleu","hex":"#1565C0"}]'::jsonb,
  35,
  true,
  'popular'
)
ON CONFLICT (slug) DO NOTHING;
