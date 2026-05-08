#!/usr/bin/env bash

set -euo pipefail

OUTPUT_DIR="wikidata-slice"
OUTPUT_FILE="wikidata-slice.ttl"

# Wikimedia asks automated clients to send a descriptive User-Agent.
# This does NOT send an email. It is only text in the HTTP request header.
UA="llm-assisted-kg-development/0.1 (https://github.com/YOUR_USERNAME/llm-assisted-kg-development)"

mkdir -p "$OUTPUT_DIR"

declare -a IDS=(
  "Q51797"      # Princess Leia
  "Q15136385"   # Princess Leia's bikini
  "Q125307040"  # Princess Leia Organa miniature action figure
  "Q51746"      # Luke Skywalker
  "Q51802"      # Han Solo
)

echo "Downloading Wikidata entities..."

for ID in "${IDS[@]}"; do
  URL="https://www.wikidata.org/wiki/Special:EntityData/${ID}.ttl?flavor=dump"
  OUT="${OUTPUT_DIR}/${ID}.ttl"

  echo "Downloading ${ID}..."
  curl -L -A "$UA" "$URL" -o "$OUT"
done

echo "Merging files into ${OUTPUT_DIR}/${OUTPUT_FILE}..."

cat \
  "${OUTPUT_DIR}/Q51797.ttl" \
  "${OUTPUT_DIR}/Q15136385.ttl" \
  "${OUTPUT_DIR}/Q125307040.ttl" \
  "${OUTPUT_DIR}/Q51746.ttl" \
  "${OUTPUT_DIR}/Q51802.ttl" \
  > "${OUTPUT_DIR}/${OUTPUT_FILE}"

echo "Done."
echo "Created: ${OUTPUT_DIR}/${OUTPUT_FILE}"