#!/bin/sh

source .env

ITEM_IDS=$(jq '[.[] | .id]' "${FAVORITE_ITEMS_JSON_PATH}")
echo "{\"resolved_item_ids\": $ITEM_IDS}" | jq . > "$RESOLVED_ITEM_JSON_PATH"

echo "[INFO] updated ${RESOLVED_ITEM_JSON_PATH}"