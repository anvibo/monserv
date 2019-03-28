#activate swap
fallocate -l 2G /swapfile
dd if=/dev/zero of=/swapfile bs=1024 count=2097152
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

#install gcsfuse
export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s`
echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y gcsfuse

#mount gcs bucket
mkdir -p /storage/gcs1
echo "anvibo-docker-storage-1 /storage/gcs1 gcsfuse rw,auto,user" >> /etc/fstab
mount /storage/gcs1

#mount attached disk
sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
mkdir -p /storage/hdd1
mount -o discard,defaults /dev/sdb /storage/hdd1
chmod a+w /storage/hdd1
echo UUID=`blkid -s UUID -o value /dev/sdb` /storage/hdd1 ext4 discard,defaults,nofail 0 2 | tee -a /etc/fstab

#install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sed -i 's/\/usr\/bin\/dockerd.*/\/usr\/bin\/dockerd/' /lib/systemd/system/docker.service
systemctl daemon-reload
echo '{ "hosts": ["tcp://0.0.0.0:2376", "fd://"] }' > /etc/docker/daemon.json
systemctl restart docker

#initialize docker swarm
docker swarm init

#install local-persist plugin
curl -fsSL https://raw.githubusercontent.com/CWSpear/local-persist/master/scripts/install.sh | sudo bash

#install terraform and git
wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
apt install -y unzip git
unzip terraform_0.11.11_linux_amd64.zip
mv terraform /usr/local/bin/

#deploying services
git clone https://github.com/anvibo/monserv.git
cd monserv/services
terraform init
terraform apply -auto-approve 