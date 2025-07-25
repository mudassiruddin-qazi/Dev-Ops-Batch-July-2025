#!/bin/bash

# Path where logs will be generated
TARGET_DIR="/home/front-end-user/front-end-data"

# Total files and size per file (in MB)
TOTAL_FILES=100
SIZE_PER_FILE_MB=5

# Ensure target directory exists
mkdir -p "$TARGET_DIR"

echo "Generating $TOTAL_FILES log files of ~$SIZE_PER_FILE_MB MB each at $TARGET_DIR..."

# Sample log entry
generate_log_line() {
  echo "$(date '+%d/%b/%Y:%H:%M:%S %z') $(shuf -n 1 -e 192.168.0.{1..255}) - - [$(date '+%d/%b/%Y:%H:%M:%S %z')] \"GET /index.html HTTP/1.1\" 200 $(shuf -i 1000-5000 -n 1)"
}

# Generate files
for i in $(seq -w 1 $TOTAL_FILES); do
  FILE="$TARGET_DIR/log_$i.log"
  echo "Creating $FILE..."

  > "$FILE"
  while [[ $(du -m "$FILE" | cut -f1) -lt $SIZE_PER_FILE_MB ]]; do
    generate_log_line >> "$FILE"
  done
done

echo "✅ Log generation complete: 100 files, ~500MB total in $TARGET_DIR"
