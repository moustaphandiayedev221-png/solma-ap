-- =====================================================
-- Migration: Système de livraison mondial
-- Création table delivery_zones + extension adresses
-- =====================================================

-- Table des zones de livraison
-- country_code: code ISO 3166-1 alpha-2 (ex: SN, FR)
-- region: nom de la région/état (null = montant par défaut pour tout le pays)
-- amount: montant de livraison
-- currency: devise (XOF, EUR, etc.)
CREATE TABLE IF NOT EXISTS delivery_zones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  country_code VARCHAR(2) NOT NULL,
  country_name VARCHAR(100) NOT NULL,
  region VARCHAR(150),
  amount DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(3) NOT NULL DEFAULT 'XOF',
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(country_code, region)
);

-- Index pour recherche rapide client
CREATE INDEX IF NOT EXISTS idx_delivery_zones_country_region
  ON delivery_zones(country_code, region)
  WHERE is_active = true;

-- Zone par défaut mondial (country_code = '*' pour fallback)
-- Insérer via l'admin si besoin

-- Colonnes optionnelles pour adresses (région + code pays ISO)
ALTER TABLE addresses
  ADD COLUMN IF NOT EXISTS region VARCHAR(150),
  ADD COLUMN IF NOT EXISTS country_code VARCHAR(2);

-- Commentaires
COMMENT ON TABLE delivery_zones IS 'Zones de livraison par pays et région avec montants';
COMMENT ON COLUMN delivery_zones.region IS 'Région/État - null = montant par défaut pour tout le pays';
COMMENT ON COLUMN addresses.region IS 'Région/État du client pour calcul livraison';
COMMENT ON COLUMN addresses.country_code IS 'Code ISO pays (SN, FR, etc.) pour calcul livraison';
