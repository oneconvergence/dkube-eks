# RKE installation

## Requirements
1. Need a system (ubuntu/centos) with Public IP address.
2. Install docker on it. Please follow below link to install docker.

   [For ubuntu-18.04](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04)
   [For centos-7](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-centos-7)

3. Configure ssh key to access the node. Follow [this link](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-2) to do so.
   

## Install RKE
1. Update terraform-rke.ini with node details.
2. Run following command to start cluster installation.
```
   bash rke.sh
```
3. Try accessing kubernetes cluster using kubectl as shown below.
```
   export KUBECONFIG=kube_config_cluster.yml
   kubectl get node -o wide           # to list node
   kubectl get po --all-namespaces    # to list all pods
```

## To uninstall RKE cluster
```
   ./terraform destroy --auto-approve
```

Note: This scripts only support single node RKE cluster.
