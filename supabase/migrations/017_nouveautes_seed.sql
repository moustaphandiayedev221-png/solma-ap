-- Seed des nouveautés (contenu publicitaire pour la section Nouveautés)
-- Insertion uniquement si la table est vide (évite doublons en cas de ré-exécution)
DO $$
DECLARE
  pid_revolution_kids UUID;
  pid_revolution_women UUID;
  pid_jordan UUID;
BEGIN
  IF (SELECT COUNT(*) FROM public.nouveautes) = 0 THEN
    -- Récupérer les IDs des produits existants pour les lier
    SELECT id INTO pid_revolution_kids FROM public.products WHERE slug = 'nike-revolution-7-kids' LIMIT 1;
    SELECT id INTO pid_revolution_women FROM public.products WHERE slug = 'nike-revolution-7-women' LIMIT 1;
    SELECT id INTO pid_jordan FROM public.products WHERE slug = 'air-jordan-1-retro-high' LIMIT 1;

    INSERT INTO public.nouveautes (title, price, image_url, label, product_id, sort_order, is_active)
    VALUES
      (
        'Nike Revolution 7 Kids',
        35000,
        COALESCE(
          (SELECT image_urls[1] FROM public.products WHERE slug = 'nike-revolution-7-kids' LIMIT 1),
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600'
        ),
        'MEILLEUR CHOIX',
        pid_revolution_kids,
        0,
        true
      ),
      (
        'Nike Revolution 7 Women',
        45000,
        COALESCE(
          (SELECT image_urls[1] FROM public.products WHERE slug = 'nike-revolution-7-women' LIMIT 1),
          'https://images.unsplash.com/photo-1600185365923-5a2580148e4a?w=600'
        ),
        'NOUVEAU',
        pid_revolution_women,
        1,
        true
      ),
      (
        'Air Jordan 1 Retro High',
        121000,
        COALESCE(
          (SELECT image_urls[1] FROM public.products WHERE slug = 'air-jordan-1-retro-high' LIMIT 1),
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600'
        ),
        'TENDANCE',
        pid_jordan,
        2,
        true
      );
  END IF;
END $$;
