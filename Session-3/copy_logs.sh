#!/bin/bash

# Local source directory
SRC_DIR="/home/front-end-user/front-end-data"

# Remote destination
REMOTE_USER="back-end-user"
REMOTE_HOST="10.128.0.33"
REMOTE_DIR="/home/back-end-user/front-end-server-backup"

echo "🔄 Copying files from $SRC_DIR to $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR..."

# Perform the copy
scp -r "$SRC_DIR"/* "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"

# Check if copy succeeded
if [ $? -eq 0 ]; then
  echo "✅ Files copied successfully!"
else
  echo "❌ Failed to copy files!"
fi
