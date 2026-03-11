-- Colways - Seed catégories Men, Women, Kids + produits par catégorie
-- À exécuter dans Supabase SQL Editor (après 001_initial_schema.sql)
-- Si les catégories existent déjà (001), les INSERT sont ignorés (ON CONFLICT DO NOTHING).

-- ========== CATEGORIES (Men, Women, Kids) ==========
-- Si 001_initial_schema.sql a déjà inséré Men, Women, Kids, rien n'est dupliqué (ON CONFLICT).
-- "All" peut rester en base ou être supprimé ; l'app ajoute "All" en premier dans les chips.
INSERT INTO public.categories (name, slug) VALUES
  ('Men', 'men'),
  ('Women', 'women'),
  ('Kids', 'kids')
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name;

-- ========== PRODUITS MEN ==========
INSERT INTO public.products (
  category_id, name, slug, description, price, compare_at_price,
  image_urls, sizes, colors, stock, is_featured, section
)
SELECT
  c.id,
  'Air Jordan 1 Retro High',
  'air-jordan-1-retro-high-men',
  'Iconic silhouette with premium leather and Air cushioning. A streetwear essential.',
  121.00, 145.00,
  ARRAY['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600', 'https://images.unsplash.com/photo-1556906781-9a412961c28c?w=600'],
  ARRAY['38','40','42','44','46'],
  '[{"name":"Noir","hex":"#1A1A1A"},{"name":"Blanc","hex":"#F5F5F5"},{"name":"Rouge","hex":"#E53935"}]'::jsonb,
  50, true, 'popular'
FROM public.categories c WHERE c.slug = 'men'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.products (category_id, name, slug, description, price, compare_at_price, image_urls, sizes, colors, stock, is_featured, section)
SELECT c.id, 'Nike Dunk Low', 'nike-dunk-low-men', 'Classic basketball design reimagined. Versatile and timeless.', 115.00, 130.00,
  ARRAY['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600', 'https://images.unsplash.com/photo-1560769629-975bc94dc1f4?w=600'],
  ARRAY['38','40','42','44','46'], '[{"name":"Noir","hex":"#1A1A1A"},{"name":"Blanc","hex":"#FFFFFF"}]'::jsonb, 45, true, 'popular'
FROM public.categories c WHERE c.slug = 'men'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.products (category_id, name, slug, description, price, compare_at_price, image_urls, sizes, colors, stock, is_featured, section)
SELECT c.id, 'Nike Air Max 90', 'nike-air-max-90-men', 'Visible Air cushioning and durable design. A running icon since 1990.', 140.00, 160.00,
  ARRAY['https://images.unsplash.com/photo-1600185365923-5a2580148e4a?w=600', 'https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?w=600'],
  ARRAY['38','40','42','44','46'], '[{"name":"Gris","hex":"#616161"},{"name":"Blanc","hex":"#FFFFFF"}]'::jsonb, 35, true, 'sports'
FROM public.categories c WHERE c.slug = 'men'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.products (category_id, name, slug, description, price, compare_at_price, image_urls, sizes, colors, stock, is_featured, section)
SELECT c.id, 'Nike Pegasus 40', 'nike-pegasus-40-men', 'Responsive foam and secure fit. Built for runners who demand comfort.', 130.00, 150.00,
  ARRAY['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600'],
  ARRAY['40','42','44','46'], '[{"name":"Bleu","hex":"#1565C0"},{"name":"Noir","hex":"#1A1A1A"}]'::jsonb, 25, false, 'sports'
FROM public.categories c WHERE c.slug = 'men'
ON CONFLICT (slug) DO NOTHING;

-- ========== PRODUITS WOMEN ==========
INSERT INTO public.products (category_id, name, slug, description, price, compare_at_price, image_urls, sizes, colors, stock, is_featured, section)
SELECT c.id, 'Nike Blazer Mid', 'nike-blazer-mid-women', 'Clean lines and premium materials. Heritage meets modern style.', 95.00, 110.00,
  ARRAY['https://images.unsplash.com/photo-1595950653107-6e8c2c2b3b3b?w=600', 'https://images.unsplash.com/photo-1600185365923-5a2580148e4a?w=600'],
  ARRAY['36','38','40','42'], '[{"name":"Blanc","hex":"#FFFFFF"},{"name":"Noir","hex":"#1A1A1A"},{"name":"Rose","hex":"#EC407A"}]'::jsonb, 40, true, 'popular'
FROM public.categories c WHERE c.slug = 'women'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.products (category_id, name, slug, description, price, compare_at_price, image_urls, sizes, colors, stock, is_featured, section)
SELECT c.id, 'Nike Air Force 1 Low', 'nike-air-force-1-low-women', 'The icon of the court. Timeless style for everyday wear.', 100.00, 115.00,
  ARRAY['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600'], ARRAY['36','38','40','42'],
  '[{"name":"Blanc","hex":"#FFFFFF"},{"name":"Rose","hex":"#F8BBD9"}]'::jsonb, 55, true, 'popular'
FROM public.categories c WHERE c.slug = 'women'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.products (category_id, name, slug, description, price, compare_at_price, image_urls, sizes, colors, stock, is_featured, section)
SELECT c.id, 'Nike Tempo Next%', 'nike-tempo-next-women', 'Responsive tempo training shoe. Speed and cushioning for daily workouts.', 170.00, 190.00,
  ARRAY['https://images.unsplash.com/photo-1600185365923-5a2580148e4a?w=600', 'https://images.unsplash.com/photo-1595950653107-6e8c2c2b3b3b?w=600'],
  ARRAY['36','38','40','42'], '[{"name":"Rose","hex":"#AD1457"},{"name":"Blanc","hex":"#FFFFFF"}]'::jsonb, 18, false, 'sports'
FROM public.categories c WHERE c.slug = 'women'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.products (category_id, name, slug, description, price, compare_at_price, image_urls, sizes, colors, stock, is_featured, section)
SELECT c.id, 'Nike Revolution 7', 'nike-revolution-7-women', 'Lightweight cushioning for a natural ride. Perfect for the gym or street.', 65.00, 75.00,
  ARRAY['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600'], ARRAY['36','38','40','42'],
  '[{"name":"Noir","hex":"#1A1A1A"},{"name":"Blanc","hex":"#FFFFFF"}]'::jsonb, 60, false, 'popular'
FROM public.categories c WHERE c.slug = 'women'
ON CONFLICT (slug) DO NOTHING;

-- ========== PRODUITS KIDS ==========
INSERT INTO public.products (category_id, name, slug, description, price, compare_at_price, image_urls, sizes, colors, stock, is_featured, section)
SELECT c.id, 'Nike Air Max 90 Kids', 'nike-air-max-90-kids', 'Same iconic look, sized for kids. Comfort and style for the little ones.', 75.00, 85.00,
  ARRAY['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600', 'https://images.unsplash.com/photo-1608236647042-f2d6c44958b2?w=600'],
  ARRAY['28','30','32','34','36'], '[{"name":"Bleu","hex":"#1565C0"},{"name":"Blanc","hex":"#FFFFFF"},{"name":"Rouge","hex":"#E53935"}]'::jsonb, 40, true, 'popular'
FROM public.categories c WHERE c.slug = 'kids'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.products (category_id, name, slug, description, price, compare_at_price, image_urls, sizes, colors, stock, is_featured, section)
SELECT c.id, 'Nike Revolution 7 Kids', 'nike-revolution-7-kids', 'Lightweight and durable. Perfect for school and play.', 55.00, 65.00,
  ARRAY['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600'], ARRAY['28','30','32','34','36'],
  '[{"name":"Vert","hex":"#2E7D32"},{"name":"Noir","hex":"#1A1A1A"}]'::jsonb, 50, true, 'popular'
FROM public.categories c WHERE c.slug = 'kids'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.products (category_id, name, slug, description, price, compare_at_price, image_urls, sizes, colors, stock, is_featured, section)
SELECT c.id, 'Nike Dunk Low Kids', 'nike-dunk-low-kids', 'Classic Dunk design for kids. Easy to put on and take off.', 70.00, 80.00,
  ARRAY['https://images.unsplash.com/photo-1560769629-975bc94dc1f4?w=600', 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600'],
  ARRAY['28','30','32','34','36'], '[{"name":"Blanc","hex":"#FFFFFF"},{"name":"Rose","hex":"#F8BBD9"},{"name":"Bleu","hex":"#42A5F5"}]'::jsonb, 35, false, 'sports'
FROM public.categories c WHERE c.slug = 'kids'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.products (category_id, name, slug, description, price, compare_at_price, image_urls, sizes, colors, stock, is_featured, section)
SELECT c.id, 'Nike Flex Runner 2 Kids', 'nike-flex-runner-2-kids', 'Flexible sole for natural movement. Ideal for running and play.', 50.00, 58.00,
  ARRAY['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600'], ARRAY['28','30','32','34','36'],
  '[{"name":"Orange","hex":"#EF6C00"},{"name":"Noir","hex":"#1A1A1A"}]'::jsonb, 45, false, 'sports'
FROM public.categories c WHERE c.slug = 'kids'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.products (category_id, name, slug, description, price, compare_at_price, image_urls, sizes, colors, stock, is_featured, section)
SELECT c.id, 'Jordan 1 Low Kids', 'jordan-1-low-kids', 'The Jordan 1 Low in kids sizes. Style and comfort for young fans.', 80.00, 95.00,
  ARRAY['https://images.unsplash.com/photo-1556906781-9a412961c28c?w=600', 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600'],
  ARRAY['30','32','34','36'], '[{"name":"Noir","hex":"#1A1A1A"},{"name":"Rouge","hex":"#C62828"},{"name":"Blanc","hex":"#FFFFFF"}]'::jsonb, 30, true, 'popular'
FROM public.categories c WHERE c.slug = 'kids'
ON CONFLICT (slug) DO NOTHING;
