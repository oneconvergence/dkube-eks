#!/bin/bash

display_help() {
    printf "Usage: $0 [ --get-kubeconfig ]\n"
    exit $1
}

install_utilities() {
        sudo  apt-get update -y
        sudo  apt-get install expect -y
        sudo  apt-get install python3-pip -y
        sudo  apt-get install unzip -y
        sudo  apt install crudini -y
        sudo  apt-get install sshpass -y
}

install_awscli() {
        sudo apt-get install awscli -y
        sudo pip3 install awscli --ignore-installed six
        aws --version
        if [[ "${?}" -ne 0 ]];then
                echo "awscli note installed properly ..."
                exit 0
        fi
        echo "configuring aws ..."
        access_key_id=$(crudini --get  terraform-eks.ini AWS aws_access_key_id)
        secret_access_key=$(crudini --get terraform-eks.ini AWS aws_secret_access_key)
        aws configure set aws_access_key_id $access_key_id
        aws configure set aws_secret_access_key $secret_access_key
}
install_iam_authenticator() {
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator
curl -o aws-iam-authenticator.sha256 https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator.sha256
openssl sha1 -sha256 aws-iam-authenticator
chmod +x ./aws-iam-authenticator
mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
aws-iam-authenticator help
}
install_docker() {
        command -v docker
        if [[ "${?}" -ne 0 ]];then
                VERSIONSTRING="5:18.09.2~3-0~ubuntu-bionic"
                echo "Docker does not exist\n"
                echo "installing Docker\n"
                sudo apt-get remove docker docker-engine docker.io containerd runc
                sudo apt-get -y update
                sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                sudo apt-key fingerprint 0EBFCD88
                sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
                sudo apt-get -y update
                sudo apt-get install -y docker-ce=$VERSIONSTRING docker-ce-cli=$VERSIONSTRING containerd.io
        fi
}

install_kubectl() {
        command -v kubectl
        if [[ "${?}" -ne 0 ]]; then
                echo "Kubectl does not exist\n"
                echo "Installing kubectl\n"
                curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
                chmod +x ./kubectl
                sudo mv ./kubectl /usr/local/bin/kubectl
                kubectl version
        fi
}

get_kubeconfig() {
        sudo pip3 install awscli --ignore-installed six
        sudo apt install jq -y
        EKS_core_name=$(crudini --get  terraform-eks.ini EKS-CLUSTER EKS_core_name)
        region=$(crudini --get  terraform-eks.ini EKS-CLUSTER region)
        cluster=$(aws eks list-clusters --region $region | jq ".clusters[]| select (contains(\"$EKS_core_name\"))")
        cluster=$(echo $cluster | tr -d '"')
        aws eks --region $region update-kubeconfig --name $cluster
        exit 0
}

if [ $# -gt 1 ]
then
    printf "This script takes atmost 1 argument\n"
    display_help 0
fi

getOptionalArgs() {
    for i in "$@"
    do
    case $i in
        --get-kubeconfig*)
        get_kubeconfig
        ;;
        *)
        printf "Invalid argument\n"
        display_help 0
        ;;
    esac
    done
}

if [ $# -gt 0 ]; then
        getOptionalArgs $@
else
        install_utilities
        install_awscli
        install_iam_authenticator
        install_docker
        install_kubectl
fi

