#!/bin/bash

# Source and Destination
SRC_DIR="/home/front-end-user/front-end-data/"
DEST_USER="back-end-user"
DEST_IP="10.128.0.33"
DEST_DIR="/home/back-end-user/frond-end-server-backup"

# Run rsync to copy data
rsync -avz -e ssh "$SRC_DIR" "${DEST_USER}@${DEST_IP}:${DEST_DIR}"

# Exit status
if [ $? -eq 0 ]; then
  echo "✅ Backup completed successfully."
else
  echo "❌ Backup failed."
fi
