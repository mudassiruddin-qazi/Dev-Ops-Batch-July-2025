#!/bin/bash

# ------------
# Configuration
# ------------
FRONT_VM="front-end-server"
BACK_VM="back-end-server"
ZONE="us-central1-a"

echo "⚠️ You are about to delete the following VMs:"
echo " - $FRONT_VM"
echo " - $BACK_VM"
echo ""
read -p "Are you sure you want to proceed? (yes/no): " confirm

if [[ "$confirm" == "yes" ]]; then
  echo "🗑️ Deleting $FRONT_VM..."
  gcloud compute instances delete "$FRONT_VM" --zone="$ZONE" --quiet

  echo "🗑️ Deleting $BACK_VM..."
  gcloud compute instances delete "$BACK_VM" --zone="$ZONE" --quiet

  echo "✅ Both VMs have been deleted successfully."
else
  echo "❌ Deletion cancelled by user."
fi
