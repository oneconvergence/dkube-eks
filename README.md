# Install Prerequisites

The installation requires Ubuntu 18.04

preinstall.sh installs the prerequisites to install the EKS cluster using terraform. The following packages are installed.
- python3
- awscli
- aws-iam-authenticator
- docker (required for DKube install)
- kubectl

Run the following commands to install the prerequisites.
```
# bash preinstall.sh
# source ~/.bashrc
```
# Install EKS Cluster

Edit terraform-eks.ini and fill in the required parameter values.

For k8s_version use 1.20 for DKube version 3.0.x and 1.18 for DKube version 2.2.x

Note: The user is required to have AWS AdministratorAccess

The AMI image can be determined using the commands below:
```
# CPU Image
# aws ssm get-parameter --name /aws/service/eks/optimized-ami/1.20/amazon-linux-2/recommended/image_id --region us-west-2 --query "Parameter.Value" --output text

# GPU Image
# aws ssm get-parameter --name /aws/service/eks/optimized-ami/1.20/amazon-linux-2-gpu/recommended/image_id --region us-west-2 --query "Parameter.Value" --output text
```

The AMI image ids are also available in AWS Console under Images. Filter for the following images
```
eks-node-1.20
eks-gpu-node-1.20
```

Run the following commands to deploy the EKS cluster and EFS endpoint
```
# bash eks.sh 
# kubectl get nodes #to verify if you can access the nodes
```

# Retrieve kubeconfig for pre-existing cluster
In the case of a pre-existing EKS cluser, retreive k8s config file required for DKube installation.

Edit terraform-eks.ini and fill in parameter values for [AWS] section.

Run the commands below to retrieve kubeconfig file
```
# bash preinstall.sh --get-kubeconfig
# kubectl get nodes -o wide
```

# Tear down EKS cluster
Run the commands below to teardown the EKS cluster
```
# cd eks-getting-started
# ./terraform destroy --auto-approve
```



