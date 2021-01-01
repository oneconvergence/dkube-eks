sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
sudo apt install -y docker-ce-cli=5:19.03.14~3-0~ubuntu-bionic docker-ce=5:19.03.14~3-0~ubuntu-bionic
sudo usermod -aG docker ubuntu
sudo systemctl restart docker

# nsf server setup
sudo apt install -y nfs-kernel-server
sudo mkdir -p /mnt/nfs_share
sudo chown -R nobody:nogroup /mnt/nfs_share/
sudo chmod 777 /mnt/nfs_share/
sudo sed -i -e '$a/mnt/nfs_share *(rw,sync,no_subtree_check)' /etc/exports
sudo exportfs -a
sudo systemctl restart nfs-kernel-server