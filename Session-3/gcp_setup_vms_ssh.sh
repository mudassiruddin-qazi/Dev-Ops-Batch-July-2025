#!/bin/bash

# -----------------------
# CONFIGURATION
# -----------------------
PROJECT_ID=$(gcloud config get-value project)
ZONE="us-central1-a"
MACHINE_TYPE="e2-medium"
IMAGE_FAMILY="debian-11"
IMAGE_PROJECT="debian-cloud"

FRONT_VM="front-end-server"
BACK_VM="back-end-server"
FRONT_USER="front-end-user"
BACK_USER="back-end-user"

# -----------------------
# 1. Create VM Instances
# -----------------------

echo "🚀 Creating VMs in GCP..."

gcloud compute instances create "$FRONT_VM" \
  --zone="$ZONE" \
  --machine-type="$MACHINE_TYPE" \
  --image-family="$IMAGE_FAMILY" \
  --image-project="$IMAGE_PROJECT" \
  --metadata startup-script="#!/bin/bash
    useradd -m -s /bin/bash $FRONT_USER
    mkdir -p /home/$FRONT_USER/.ssh
    chown -R $FRONT_USER:$FRONT_USER /home/$FRONT_USER/.ssh" \
  --tags=http-server

gcloud compute instances create "$BACK_VM" \
  --zone="$ZONE" \
  --machine-type="$MACHINE_TYPE" \
  --image-family="$IMAGE_FAMILY" \
  --image-project="$IMAGE_PROJECT" \
  --metadata startup-script="#!/bin/bash
    useradd -m -s /bin/bash $BACK_USER
    mkdir -p /home/$BACK_USER/.ssh
    chown -R $BACK_USER:$BACK_USER /home/$BACK_USER/.ssh" \
  --tags=http-server

# Wait for VMs to boot up
echo "⏳ Waiting for VMs to be ready..."
sleep 60

# -----------------------
# 2. Generate SSH Key on Frontend
# -----------------------

echo "🔐 Generating SSH Key on $FRONT_VM..."
gcloud compute ssh "$FRONT_USER@$FRONT_VM" --zone="$ZONE" --command "
  if [ ! -f /home/$FRONT_USER/.ssh/id_rsa ]; then
    sudo -u $FRONT_USER ssh-keygen -t rsa -b 4096 -N '' -f /home/$FRONT_USER/.ssh/id_rsa
  fi"

# -----------------------
# 3. Copy Public Key to Backend
# -----------------------

echo "📤 Copying public key to $BACK_USER@$BACK_VM..."

# Extract public key from front-end
PUB_KEY=$(gcloud compute ssh "$FRONT_USER@$FRONT_VM" --zone="$ZONE" --command "cat /home/$FRONT_USER/.ssh/id_rsa.pub" 2>/dev/null)

# Append the public key to back-end user’s authorized_keys
gcloud compute ssh "$BACK_USER@$BACK_VM" --zone="$ZONE" --command "
  echo '$PUB_KEY' | sudo tee -a /home/$BACK_USER/.ssh/authorized_keys
  sudo chown $BACK_USER:$BACK_USER /home/$BACK_USER/.ssh/authorized_keys
  sudo chmod 600 /home/$BACK_USER/.ssh/authorized_keys
  sudo chmod 700 /home/$BACK_USER/.ssh"

# -----------------------
# 4. ✅ TESTING INSTRUCTION
# -----------------------

BACKEND_INTERNAL_IP=$(gcloud compute instances describe "$BACK_VM" --zone="$ZONE" --format='get(networkInterfaces[0].networkIP)')

echo ""
echo "✅ DONE! Now you can test passwordless SSH:"
echo ""
echo "🔗 Run this from your local terminal:"
echo "gcloud compute ssh $FRONT_USER@$FRONT_VM --zone=$ZONE --command 'ssh $BACK_USER@$BACKEND_INTERNAL_IP'"
