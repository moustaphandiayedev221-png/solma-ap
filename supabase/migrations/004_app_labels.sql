-- Colways - Libellés UI depuis la base (table app_labels)
-- Tous les textes de l'app (ex. "Tout", "Tout voir") peuvent venir de cette table.
-- Clé = identifiant (ex. categoryAll, seeAll), locale = fr/en, value = texte affiché.
-- À exécuter dans Supabase SQL Editor.

CREATE TABLE IF NOT EXISTS public.app_labels (
  key TEXT NOT NULL,
  locale TEXT NOT NULL,
  value TEXT NOT NULL,
  PRIMARY KEY (key, locale)
);

ALTER TABLE public.app_labels ENABLE ROW LEVEL SECURITY;

CREATE POLICY "App labels are readable by everyone"
  ON public.app_labels FOR SELECT
  USING (true);

-- Autres libellés UI (ex. seeAll, welcomeBack) : à insérer selon besoin.
-- Le libellé "Tout" vient de la table categories (catégorie slug 'all'), pas d'ici.
