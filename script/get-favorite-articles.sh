#!/bin/sh

set -e

source .env

API_URL="https://readwise.io/api/v3/list/"
PAGE_CURSOR=""
HAS_MORE=true
ALL_ITEMS="[]"
TOTAL_COUNT=""
FETCHED_COUNT=0
ITEMS_PER_PAGE=100
TAG="favorite"

mkdir -p bin

echo "[INFO] Fetching articles from Readwise..."

while [ "$HAS_MORE" = true ]; do
  while :; do
    if [ -z "$PAGE_CURSOR" ]; then
      RESPONSE=$(mktemp)
      HEADER=$(mktemp)
      echo "[INFO] Requesting first page without nextPageCursor"
      curl -s -D "$HEADER" -o "$RESPONSE" -H "Authorization: Token $READWISE_ACCESS_TOKEN" -H "Content-Type: application/json" "$API_URL?tag=favorite"
    else
      RESPONSE=$(mktemp)
      HEADER=$(mktemp)
      echo "[INFO] Requesting next page with nextPageCursor: $PAGE_CURSOR"
      curl -s -D "$HEADER" -o "$RESPONSE" -H "Authorization: Token $READWISE_ACCESS_TOKEN" -H "Content-Type: application/json" "$API_URL?tag=favorite&pageCursor=$PAGE_CURSOR"
    fi

    HTTP_STATUS=$(head -n 1 "$HEADER" | awk '{print $2}')
    if [ "$HTTP_STATUS" = "429" ]; then
      RETRY_AFTER=$(grep -i '^Retry-After:' "$HEADER" | awk '{print $2}' | tr -d '\r')
      if [ -z "$RETRY_AFTER" ]; then
        RETRY_AFTER=10
      fi
      echo "[WARN] Rate limit exceeded. Retrying after $RETRY_AFTER seconds..."
      sleep "$RETRY_AFTER"
      rm -f "$RESPONSE" "$HEADER"
      continue
    elif [ "$HTTP_STATUS" != "200" ]; then
      echo "[ERROR] Failed to retrieve articles (HTTP $HTTP_STATUS)" >&2
      cat "$RESPONSE"
      rm -f "$RESPONSE" "$HEADER"
      exit 1
    fi
    break
  done

  RESPONSE_BODY=$(cat "$RESPONSE")
  RESPONSE_BODY_CLEAN=$(echo "$RESPONSE_BODY" | tr -d '[:cntrl:]' | sed 's/\\"//g')

  # 最初のレスポンスで全件数を取得
  if [ -z "$TOTAL_COUNT" ]; then
    TOTAL_COUNT=$(echo "$RESPONSE_BODY_CLEAN" | jq -r '.count')
    if [ -z "$TOTAL_COUNT" ] || [ "$TOTAL_COUNT" = "null" ]; then
      echo "[INFO] TOTAL_COUNT not found in the response. TOTAL_COUNT=${TOTAL_COUNT}"
      exit 1
    fi
  fi

  # Extract only items with 'favorite' tag and required fields
  ITEMS=$(echo "$RESPONSE_BODY_CLEAN" | jq '[.results[] | select(.tags | has("favorite")) | {
    id, url, source_url, title, author, site_name, published_date, created_at, updated_at, last_moved_at
  }]')

  ITEM_COUNT=$(echo "$RESPONSE_BODY_CLEAN" | jq '.results | length')
  FETCHED_COUNT=$((FETCHED_COUNT + ITEM_COUNT))

  ALL_ITEMS=$(echo "$ALL_ITEMS $ITEMS" | jq -s 'add | flatten')

  echo "[INFO] Processed $FETCHED_COUNT / $TOTAL_COUNT articles."

  # Pagination
  if [ "$FETCHED_COUNT" -ge "$TOTAL_COUNT" ]; then
    HAS_MORE=false
  else
    PAGE_CURSOR=$(echo "$RESPONSE_BODY_CLEAN" | jq -r '.nextPageCursor // empty')
    echo "[INFO] PAGE_CURSOR update to $PAGE_CURSOR"
  fi
  rm -f "$RESPONSE" "$HEADER"
done

echo "$ALL_ITEMS" | jq 'sort_by(.last_moved_at) | reverse' > ${FAVORITE_ITEMS_JSON_PATH}

echo "[INFO] Done: Saved to ${FAVORITE_ITEMS_JSON_PATH} ."
