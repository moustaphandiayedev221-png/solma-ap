-- =====================================================
-- 020 – Extension des avis (système professionnel)
-- =====================================================

-- Colonnes additionnelles pour reviews
ALTER TABLE public.reviews
  ADD COLUMN IF NOT EXISTS title TEXT,
  ADD COLUMN IF NOT EXISTS pros TEXT,
  ADD COLUMN IF NOT EXISTS cons TEXT,
  ADD COLUMN IF NOT EXISTS verified_purchase BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS helpful_count INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS not_helpful_count INTEGER DEFAULT 0;

-- Table des votes "utile / pas utile" (un vote par utilisateur par avis)
CREATE TABLE IF NOT EXISTS public.review_helpful_votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id UUID NOT NULL REFERENCES public.reviews(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  helpful BOOLEAN NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(review_id, user_id)
);

ALTER TABLE public.review_helpful_votes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read helpful votes"
  ON public.review_helpful_votes FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can insert own vote"
  ON public.review_helpful_votes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own vote"
  ON public.review_helpful_votes FOR UPDATE
  USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_review_helpful_votes_review
  ON public.review_helpful_votes(review_id);

-- Fonction pour mettre à jour les compteurs helpful sur les reviews
CREATE OR REPLACE FUNCTION public.update_review_helpful_counts()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.helpful THEN
      UPDATE public.reviews SET helpful_count = helpful_count + 1 WHERE id = NEW.review_id;
    ELSE
      UPDATE public.reviews SET not_helpful_count = not_helpful_count + 1 WHERE id = NEW.review_id;
    END IF;
  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.helpful != NEW.helpful THEN
      IF OLD.helpful THEN
        UPDATE public.reviews SET helpful_count = helpful_count - 1, not_helpful_count = not_helpful_count + 1 WHERE id = NEW.review_id;
      ELSE
        UPDATE public.reviews SET not_helpful_count = not_helpful_count - 1, helpful_count = helpful_count + 1 WHERE id = NEW.review_id;
      END IF;
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    IF OLD.helpful THEN
      UPDATE public.reviews SET helpful_count = helpful_count - 1 WHERE id = OLD.review_id;
    ELSE
      UPDATE public.reviews SET not_helpful_count = not_helpful_count - 1 WHERE id = OLD.review_id;
    END IF;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_review_helpful_votes ON public.review_helpful_votes;
CREATE TRIGGER trg_review_helpful_votes
  AFTER INSERT OR UPDATE OR DELETE ON public.review_helpful_votes
  FOR EACH ROW EXECUTE FUNCTION public.update_review_helpful_counts();
