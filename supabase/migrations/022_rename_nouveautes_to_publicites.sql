-- Renommage de la table nouveautes en publicites
ALTER TABLE public.nouveautes RENAME TO publicites;

-- Mise à jour des link_url des bannières (redirection vers /publicites)
UPDATE public.banners
SET link_url = '/publicites'
WHERE link_url = '/nouveautes';
