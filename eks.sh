#!/bin/bash

#######EKS-CLUSTER######
EKS_core_name=$(crudini --get terraform-eks.ini EKS-CLUSTER EKS_CORE_NAME)
vpc_cidr=$(crudini --get terraform-eks.ini EKS-CLUSTER vpc_cidr)                      # Fixed CIDR block of 24
pem=$(crudini --get terraform-eks.ini EKS-CLUSTER pem)                                # aws pem file to access cluster
ami=$(crudini --get terraform-eks.ini EKS-CLUSTER ami)                                # AMI-id of EKS Image
instance_type=$(crudini --get terraform-eks.ini EKS-CLUSTER instance_type)            # Instance type for your cluster
region=$(crudini --get terraform-eks.ini EKS-CLUSTER region)                          # Region for your aws cluster
max_cluster_nodes=$(crudini --get terraform-eks.ini EKS-CLUSTER max_cluster_nodes)    # Maximum number of managed node groups per cluster
num_cluster_nodes=$(crudini --get terraform-eks.ini EKS-CLUSTER num_cluster_nodes)    # Number of nodes desired for current cluster
k8s_version=$(crudini --get terraform-eks.ini EKS-CLUSTER k8s_version)                # Kubernetes version

key=$( echo $pem | cut -d. -f1)
network=$(echo $vpc_cidr | cut -d '.' -f1-2)
installer_username=`whoami`
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
  center "EKS SCRIPT USAGE"
  printf "Please update the variables as per usage"
  printf "%-100s${NC}\n" "EKS_core_name:               Base name of your cluster"
  printf "%-100s${NC}\n" "vpc_cidr:                          First 8-bit field value IPv4"
  printf "%-100s${NC}\n" "pem:                         aws pem file to access cluster"
  printf "%-100s${NC}\n" "instance_type:               Instance type for your cluster"
  printf "%-100s${NC}\n" "region:                      Region for your aws cluster"
  printf "%-100s${NC}\n" "max_cluster_nodes:           Maximum number of managed node groups per cluster"
  printf "%-100s${NC}\n" "num_cluster_nodes:           Number of nodes desired for current"
  printf "%-100s${NC}\n" "installer_user_passwd:       Needed only if setup requires password on sudo permission"
  printf "%-100s${NC}\n" "dkubeuser:                   Username for dkube"
  printf "%-100s${NC}\n" "dkubepass:                   password for dkube user"
  exit $1
}

#checking for root or not
if [ $(id -u) = "0" ]; then
          export PATH=$PATH:$HOME/bin
fi
#Untar the tar file. i.e terraform script
tar -xvf eks-script3.tar

if [[ -e terraform_0.12.9_linux_amd64.zip ]];then
  unzip terraform_0.12.9_linux_amd64.zip
  if [[ "${?}" -ne 0 ]];then
        echo "Something went wrong !! File terraform_0.12.9_linux_amd64.zip not unzipped."
        exit 1
  fi
  mv terraform eks-getting-started
  if [[ "${?}" -ne 0 ]];then
        echo "Something went wrong !! Could not move file terraform into eks-getting-started directory."
        exit 1
  fi
fi

#Changed to working directory
#echo $installer_user_passwd | sudo -S chown -R ${installer_username}:${installer_username} eks-getting-started
cd eks-getting-started


#Changed all resource name in terraform script
sed -i -e "s/demo/$EKS_core_name-&/g" -e "/version *= \"[0-9.]*\"/s/\"[0-9.]*\"/\"$k8s_version\"/" eks-cluster.tf
sed -i "s/demo/$EKS_core_name-&/g" variables.tf
sed -i -e "s/demo/$EKS_core_name-&/g" -e "/image_id *= \"ami-[a-zA-Z0-9]*\"/s/\"ami-[a-zA-Z0-9]*\"/\"$ami\"/" -e "/instance_type *= \"[a-zA-Z0-9.]*\"/s/\"[a-zA-Z0-9.]*\"/\"$instance_type\"/" -e "/key_name *= \"[a-zA-Z0-9-]*\"/s/\"[a-zA-Z0-9-]*\"/\"$key\"/" -e "/max_size *= [0-9]/s/[0-9]/$max_cluster_nodes/" -e "/desired_capacity *= [0-9]/s/[0-9]/$num_cluster_nodes/" eks-worker-nodes.tf
sed -i "s/demo/$EKS_core_name-&/g" outputs.tf
sed -i "s/1.12/$k8s_version/g" variables.tf
sed -i "s/demo/$EKS_core_name-&/g" efs.tf
sed -i "s/\"us-west-2\"/\"$region\"/" providers.tf
sed -i -e "s/demo/$EKS_core_name-&/g" -e "s|\"10.0.0.0/16\"|\"$vpc_cidr\"|" -e "s/\"10.0.\${count.index}.0\/24\"/\"$network.\${count.index}.0\/24\"/" vpc.tf
rm -rf terraform.tfstate terraform.tfstate.backup
#Init Terraform
./terraform init
touch result.txt
#Apply Terraform
./terraform apply -auto-approve -no-color |  tee result.txt
if [[ "${?}" -ne 0 ]];then
  echo "Something went wrong !! terroform apply Failed !!"
  exit 1
fi

#Read terraform apply output in yaml file
sed -n '/config_map_aws_auth =/,/efs_server_ip/p'  result.txt > config_map_aws_auth.yaml
sed -i '1d; $d' config_map_aws_auth.yaml
sed -i '1d' config_map_aws_auth.yaml
sed -n '/kubeconfig =/,//p'  result.txt > kubeconfig
sed -i 's/\x1b\[[0-9;]*m//g' kubeconfig
sed -i '1d' kubeconfig
sed -i '1d' kubeconfig
#if [ ! -d $HOME/.kube ];then
#  mkdir  $HOME/.kube
#fi
#echo $installer_user_passwd | sudo -S chown -R $installer_username:$installer_username $PWD/kubeconfig
#cp kubeconfig $HOME/.kube/config
#sudo mkdir -p /root/.kube
#echo $installer_user_passwd | sudo -S cp kubeconfig /root/.kube/config

sleep 3m
#Apply the yaml file , what we got above
kubectl apply -f config_map_aws_auth.yaml --kubeconfig=$PWD/kubeconfig
if [[ "${?}" -ne 0 ]];then
        echo "Something went wrong !! Applying config_map_aws_auth.yaml Failed !!"
        exit 1
fi
#echo $installer_user_passwd | sudo -S chown -R $installer_username:$installer_username $PWD/kubeconfig
