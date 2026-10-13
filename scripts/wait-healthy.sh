#!/usr/bin/env bash
# Attend qu'un conteneur Docker soit "healthy".
# Usage : wait-healthy.sh <conteneur> [tentatives_max]
set -euo pipefail

CONTAINER="${1:?usage: $0 <conteneur> [tentatives_max]}"
MAX="${2:-20}"

for i in $(seq 1 "$MAX"); do
  if [ "$(docker inspect --format '{{.State.Running}}' "$CONTAINER")" != "true" ]; then
    echo "Container $CONTAINER is not running (crashed)"
    break
  fi
  STATUS=$(docker inspect --format '{{.State.Health.Status}}' "$CONTAINER")
  echo "Attempt $i/$MAX: $STATUS"
  case "$STATUS" in
    healthy)   exit 0 ;;
    unhealthy) break ;;
  esac
  sleep 3
done

echo "::error::Container $CONTAINER did not become healthy"
docker inspect --format '{{json .State.Health}}' "$CONTAINER" || true
docker logs --tail 50 "$CONTAINER" || true
exit 1
