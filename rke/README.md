# RKE Install on Datacenter VM

#### Requirements
1. Need a system (ubuntu/centos) with Public IP address.
2. Install docker on it. Please follow below steps to install docker.

   For Ubuntu-18.04:
```
   sudo apt update
   sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
   sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
   sudo apt update
   sudo apt install docker-ce-cli=5:19.03.14~3-0~ubuntu-bionic docker-ce=5:19.03.14~3-0~ubuntu-bionic
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

#### Install
1. Update terraform-rke.ini with below details,
```
   node_provider=datacenter
   user=dkube
   ipaddress=<node-ip>
```
2. Copy ssh private key to "ssh-rsa" file in rke folder and change permission using "chmod 400 ssh-rsa" command.
3. Run following command to start cluster installation.
```
   bash rke.sh
```

#### Uninstall
```
   ./terraform destroy --auto-approve
```
   

# RKE Install on GCP/AWS cloud provider nodes

#### Install
1. Update terraform-rke.ini with below details
   FOR RKE-GCP:
```
   node_provider=gcp
   user=ubuntu
   gcp_instance_name=jenkins-dkube
   gcp_gpu_count=4
```

   FOR RKE-AWS:
```
   node_provider=aws
   user=ubuntu
   aws_resource_name=dkube-rke-aws
```

2. Generate ssh key private and public using opnesssl command.

3. Copy ssh private key to "ssh-rsa" file in rke folder and change permission using "chmod 400 ssh-rsa" command

4. Copy ssh public key to "ssh-rsa.pub" file in aws/gcp folder based on RKE-AWS or RKE-GCP deployment.

5. Run following command to start cluster installation.
```
   bash rke.sh
```

#### Uninstall
cloud-provider-folder = aws/gcp based on RKE-AWS/RKE-GCP.
```
   cd rke
   ./terraform destroy --auto-approve
   cd <cloud-provider-folder>
   ./terraform destroy --auto-approve
```

Note: This scripts only support single node RKE cluster.
