#!/bin/bash


kubernetes_version=$(crudini --get terraform-rke.ini RKE-CLUSTER kubernetes_version)     #Kubernetes version
network_plugin=$(crudini --get terraform-rke.ini RKE-CLUSTER plugin)                     #Network plugin
ipaddress=$(crudini --get terraform-rke.ini RKE-CLUSTER ipaddress)                       #Node IP address
user=$(crudini --get terraform-rke.ini RKE-CLUSTER user)                                 #Node Username
ssh_key_path=$(crudini --get terraform-rke.ini RKE-CLUSTER ssh_key_path)                 #ssh key to access node

source $HOME/.bashrc
center(){
  BOLD='\033[1m'
  NORMAL='\e[21m'
  NONE='\033[00m'
  GREEN='\033[38;5;155m'
  text="$*"
  printf "${GREEN}${BOLD}%*s${NORMAL}${NONE}\n" $(( ($(tput cols) + ${#text}) / 2)) "$text"
}

display_help() {
  NC='\e\033[00m'
  center "RKE SCRIPT USAGE"
  printf "Please update the variables as per usage"
  printf "%-100s${NC}\n" "kubernetes_version:       Rancher kubernetes version"
  printf "%-100s${NC}\n" "plugin:                   Network plugin for kubernetes"
  printf "%-100s${NC}\n" "ipaddress:                IP address of the node"
  printf "%-100s${NC}\n" "user:                     Username of the node"
  printf "%-100s${NC}\n" "ssh_key_path:             SSH key to access the node"
  exit $1
}

#checking for root or not
if [ $(id -u) = "0" ]; then
          export PATH=$PATH:$HOME/bin
fi

# cleaning stale files if present
rm -rf main.tf provider.tf terraform terraform.d terraform.tfstate terraform.tfstate.backup .terraform.lock.hcl

# extract rke terraform scripts
tar -xvf rke_scripts.tar

# extract terraform and provider modules
if [[ -e terraform_0.14.0_linux_amd64.zip ]];then
  unzip terraform_0.14.0_linux_amd64.zip
  if [[ "${?}" -ne 0 ]];then
        echo "Something went wrong !! File terraform_0.14.0_linux_amd64.zip not unzipped."
        exit 1
  fi
fi

# update terraform script with cluster details
sed -i -e "s/NODEIP/$ipaddress/g" main.tf
sed -i -e "s/NODEUSER/$user/g" main.tf
sed -i -e "s#SSHKEYPATH#$ssh_key_path#g" main.tf
if [ -z "$kubernetes_version" ]; then
    echo "kubernetes version is not provided, using v1.16.15-rancher1-3"
    sed -i -e "s/kubernetes_version =.*/kubernetes_version = \"v1.16.15-rancher1-3\"/g" main.tf
else
    sed -i -e "s/kubernetes_version =.*/kubernetes_version = \"$kubernetes_version\"/g" main.tf
fi

if [ -z "$network_plugin" ]; then
    echo "network plugin is not provided, using flannel"
    sed -i -e "s/plugin =.*/plugin = \"flannel\"/g" main.tf
else
    sed -i -e "s/plugin =.*/plugin = \"$network_plugin\"/g" main.tf
fi

#Changed all resource name in terraform script
#Init Terraform
./terraform init

# validate terraform script
./terraform validate

touch terraform_apply_result.txt
#Apply Terraform
./terraform apply -auto-approve -no-color | tee terraform_apply_result.txt
if [[ "${?}" -ne 0 ]];then
  echo "Something went wrong !! terroform apply Failed !!"
  exit 1
fi

#Update kubeconfig
#if [ ! -d $HOME/.kube ];then
#  mkdir  $HOME/.kube
#fi
echo "Saving cluster config to ./kubeconfig file."
cp kube_config_cluster.yml kubeconfig
