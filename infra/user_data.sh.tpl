#!/bin/bash

set -e

DISK_PATH="/dev/disk/by-id/scsi-0DO_Volume_spec-forge-data"
while [ ! -e "$DISK_PATH" ]; do sleep 1; done
blkid "$DISK_PATH" || mkfs.ext4 "$DISK_PATH"
mkdir -p /mnt/data
mount -o discard,defaults "$DISK_PATH" /mnt/data
UUID=$(blkid -s UUID -o value "$DISK_PATH")
grep -q "$UUID" /etc/fstab || echo \
  "UUID=$UUID /mnt/data ext4 discard,defaults,nofail 0 2" >> /etc/fstab
mount -a
mkdir -p /mnt/data/{certs,vhost,html,acme}

fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
grep -q '/swapfile' /etc/fstab || echo \
  '/swapfile none swap sw 0 0' >> /etc/fstab

apt-get update

apt-get install -y unattended-upgrades
echo 'APT::Periodic::Update-Package-Lists "1";' > /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::Unattended-Upgrade "1";' >> /etc/apt/apt.conf.d/20auto-upgrades

apt-get install -y docker.io docker-compose-v2
docker network create shared_network || true

mkdir -p /opt/proxy
cat <<EOF > /opt/proxy/docker-compose.yml
${docker_compose_yml}
EOF

docker compose -f /opt/proxy/docker-compose.yml up -d