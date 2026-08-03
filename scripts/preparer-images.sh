#!/bin/sh
# Prépare les images du tournoi à partir des photos brutes de photos-source/.
# Usage : bash scripts/preparer-images.sh   (depuis la racine du projet, ou n'importe où)

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
RACINE=$(cd "$SCRIPT_DIR/.." && pwd)
SOURCE="$RACINE/photos-source"
SORTIE="$RACINE/images"
LARGEUR=900
QUALITE=78
SEUIL_OCTETS=4194304

# 1. ImageMagick installé ?
if command -v magick >/dev/null 2>&1; then
  CONVERT="magick"
elif command -v convert >/dev/null 2>&1; then
  CONVERT="convert"
else
  echo "ImageMagick est requis mais introuvable. Installe-le avec :"
  echo "  brew install imagemagick"
  exit 1
fi

# 2. On vide puis régénère images/.
rm -rf "$SORTIE"
mkdir -p "$SORTIE"

# 3. Conversion de chaque photo, dans l'ordre alphabétique.
compteur=0
manifeste_entrees=""

for photo in "$SOURCE"/*; do
  [ -f "$photo" ] || continue
  base=$(basename "$photo")
  case "$base" in
    .gitkeep|.*) continue ;;
  esac
  case "$base" in
    *.jpg|*.JPG|*.jpeg|*.JPEG|*.png|*.PNG|*.heic|*.HEIC) ;;
    *) continue ;;
  esac

  compteur=$((compteur + 1))
  numero=$(printf '%02d' "$compteur")
  fichier_sortie="coupe-$numero.webp"

  "$CONVERT" "$photo" -auto-orient -resize "${LARGEUR}x" -quality "$QUALITE" "$SORTIE/$fichier_sortie"

  entree="{ \"id\": $compteur, \"fichier\": \"$fichier_sortie\" }"
  if [ -z "$manifeste_entrees" ]; then
    manifeste_entrees="$entree"
  else
    manifeste_entrees="$manifeste_entrees, $entree"
  fi
done

# 4. Écriture du manifeste.
printf '{ "propositions": [ %s ] }\n' "$manifeste_entrees" > "$SORTIE/manifest.json"

# 5. Bilan.
if [ "$compteur" -eq 0 ]; then
  echo "Aucune photo trouvée dans photos-source/. Dépose des .jpg, .jpeg, .png ou .heic puis relance."
  exit 0
fi

if command -v du >/dev/null 2>&1; then
  poids_octets=$(du -sk "$SORTIE" | awk '{print $1 * 1024}')
  poids_lisible=$(du -sh "$SORTIE" | awk '{print $1}')
else
  poids_octets=0
  poids_lisible="?"
fi

echo "$compteur proposition(s) préparée(s) dans images/."
echo "Poids total du dossier : $poids_lisible"

if [ "$poids_octets" -gt "$SEUIL_OCTETS" ]; then
  echo "Attention : le dossier images/ dépasse 4 Mo, ça sera pénible en 4G."
fi
