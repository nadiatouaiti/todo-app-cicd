#!/usr/bin/env bash
# Supprime les anciennes images d'un dépôt Docker, en gardant celles passées en argument.
# Usage : cleanup-images.sh <depot> <image_a_garder> [<image_a_garder> ...]
set -euo pipefail

REPO="${1:?usage: $0 <depot> <image_a_garder>...}"
shift
KEEP=("$@")

echo "Images to keep:"
printf '  %s\n' "${KEEP[@]}"

docker images "$REPO" --format '{{.Repository}}:{{.Tag}}' | while read -r img; do
  keep=false
  for k in "${KEEP[@]}"; do
    if [ "$img" = "$k" ]; then
      keep=true
    fi
  done
  if [ "$keep" = true ]; then
    echo "Keep:   $img"
  else
    echo "Remove: $img"
    docker rmi "$img" || echo "  (could not remove $img, skipping)"
  fi
done

# Supprime les couches orphelines (images sans tag)
docker image prune -f

echo "Disk usage after cleanup:"
docker system df
