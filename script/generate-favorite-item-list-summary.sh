#!/bin/sh

source .env

INPUT_FILE="${FAVORITE_ITEMS_JSON_PATH}"
OUTPUT_FILE="${OUTPUT_FAVORITE_ITEM_LIST_FILE_PATH}"

CURRENT_DATE=$(date '+%Y/%m/%d')

# clean up the output file
echo "" > "$OUTPUT_FILE"

# Check if FRONTMATTER is set
if [ -n "${FRONT_MATTER}" ]; then
  echo "---" > "$OUTPUT_FILE"
  echo "${FRONT_MATTER}" >> "$OUTPUT_FILE"
  echo "---" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

echo "updated_at: $CURRENT_DATE" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Extract data from JSON, group by YYYY-MM, and append in markdown format
jq -r '
  map({
    "yearMonth": (.last_moved_at | split("-") | .[0:2] | join("-")),
    "title": .title,
    "url": .source_url
  }) |
  group_by(.yearMonth) |
  map({
    "yearMonth": .[0].yearMonth,
    "articles": map("- [" + .title + "](" + .url + ")")
  }) |
  sort_by(.yearMonth) | reverse |
  .[] |
  "### " + .yearMonth + "\n" + (.articles | join("\n")) + "\n"
' "$INPUT_FILE" >> "$OUTPUT_FILE"

echo "[INFO] file generated: $OUTPUT_FILE"