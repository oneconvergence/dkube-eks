# RKE installation

## Requirements
1. Need a system (ubuntu/centos) with Public IP address.
2. Install docker on it. Please follow below steps to install docker.

   For Ubuntu-18.04:
```
   sudo apt update
   sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
   sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
   sudo apt update
   sudo apt install docker-ce
   sudo usermod -aG docker $USER
   sudo systemctl restart docker
   sudo systemctl status docker
```
   For CentOS-7:
```
   sudo yum install -y yum-utils \
      device-mapper-persistent-data \
      lvm2

   sudo yum-config-manager \
       --add-repo \
       https://download.docker.com/linux/centos/docker-ce.repo

   sudo yum install -y docker-ce-19.03.14 docker-ce-cli-19.03.14
   sudo systemctl restart docker
   sudo systemctl enable docker
   sudo usermod -aG docker $USER
```

3. Configure ssh key to access the node. Follow [this link](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-2) to do so.
   

## Install RKE
1. Update terraform-rke.ini with node details.
2. Run following command to start cluster installation.
```
   bash rke.sh
```
3. Try accessing kubernetes cluster using kubectl as shown below.
```
   export KUBECONFIG=$PWD/kubeconfig
   kubectl get node -o wide           # to list node
   kubectl get po --all-namespaces    # to list all pods
```

## To uninstall RKE cluster
```
   ./terraform destroy --auto-approve
```

Note: This scripts only support single node RKE cluster.
