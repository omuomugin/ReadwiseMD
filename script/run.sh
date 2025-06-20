#!/bin/sh

source .env

echo "[INFO] running scripts ..."

echo "[INFO] getting pocket articles ..."
sh get-favorite-articles.sh

echo "[INFO] generating pocket item list summary ..."
sh generate-favorite-item-list-summary.sh

echo "[INFO] generating archive markdown file (only unresolved items) from readwise item list ..."
sh generate-unresolved-favorite-item-archive.sh

echo "[INFO] updating resolved item list ..."
sh update_resolved_item_list.sh

echo "[INFO] scripts completed."