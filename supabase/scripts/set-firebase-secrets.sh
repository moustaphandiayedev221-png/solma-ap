#!/usr/bin/env bash
# Extrait les secrets Firebase du fichier JSON du compte de service
# et les définit dans Supabase Edge Functions.
#
# Usage:
#   ./set-firebase-secrets.sh path/to/service-account.json
#   ./set-firebase-secrets.sh  (utilise firebase-service-account.json dans le même dossier)
#
# Prérequis: supabase CLI installé et connecté (supabase login)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JSON_FILE="${1:-$SCRIPT_DIR/firebase-service-account.json}"

if [ ! -f "$JSON_FILE" ]; then
  echo "Erreur: Fichier non trouvé: $JSON_FILE"
  echo ""
  echo "Usage: $0 [chemin/vers/service-account.json]"
  echo ""
  echo "Placez votre fichier JSON du compte de service Firebase dans ce dossier"
  echo "ou passez le chemin en argument."
  exit 1
fi

echo "Extraction des secrets depuis: $JSON_FILE"
echo ""

# La clé privée est convertie avec \n littéraux (comme attendu par l'Edge Function)
PROJECT_ID=$(jq -r '.project_id' "$JSON_FILE")
CLIENT_EMAIL=$(jq -r '.client_email' "$JSON_FILE")
PRIVATE_KEY=$(jq -r '.private_key | gsub("\n"; "\\n")' "$JSON_FILE")

if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "null" ]; then
  echo "Erreur: project_id introuvable dans le JSON"
  exit 1
fi
if [ -z "$CLIENT_EMAIL" ] || [ "$CLIENT_EMAIL" = "null" ]; then
  echo "Erreur: client_email introuvable dans le JSON"
  exit 1
fi
if [ -z "$PRIVATE_KEY" ] || [ "$PRIVATE_KEY" = "null" ]; then
  echo "Erreur: private_key introuvable dans le JSON"
  exit 1
fi

echo "Projet Firebase: $PROJECT_ID"
echo "Client email: $CLIENT_EMAIL"
echo ""
echo "Définition des secrets Supabase..."
echo ""

# Création du fichier .env temporaire (Supabase attend ce format)
TMP_ENV=$(mktemp)
trap "rm -f $TMP_ENV" EXIT

{
  echo "FIREBASE_PROJECT_ID=$PROJECT_ID"
  echo "FIREBASE_CLIENT_EMAIL=$CLIENT_EMAIL"
  echo "FIREBASE_PRIVATE_KEY=$PRIVATE_KEY"
} > "$TMP_ENV"

# Exécuter depuis la racine du projet (parent de supabase/)
cd "$SCRIPT_DIR/../.."

if command -v supabase &> /dev/null; then
  supabase secrets set --env-file "$TMP_ENV"
  echo ""
  echo "✅ Secrets définis avec succès."
else
  # Supabase CLI non installé : sauvegarder dans .env.firebase-secrets pour saisie manuelle
  OUTPUT_FILE="$SCRIPT_DIR/../../.env.firebase-secrets"
  cp "$TMP_ENV" "$OUTPUT_FILE"
  echo ""
  echo "⚠️  Supabase CLI non installé."
  echo ""
  echo "Fichier généré : $OUTPUT_FILE"
  echo ""
  echo "Pour définir les secrets manuellement :"
  echo "  1. Allez sur https://supabase.com/dashboard → Votre projet → Project Settings → Edge Functions"
  echo "  2. Section 'Secrets' : ajoutez les 3 variables (FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY)"
  echo "  3. Copiez les valeurs depuis le fichier .env.firebase-secrets"
  echo "  4. Supprimez le fichier après : rm $OUTPUT_FILE"
  echo ""
fi
