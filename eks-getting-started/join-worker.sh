#!/bin/bash
#echo "JOINING THE NODES ..."
#sleep 10
terraform output kubeconfig > ~/.kube/config
terraform output config_map_aws_auth > config_map_aws_auth.yaml
kubectl apply -f config_map_aws_auth.yaml
#echo "NODES JOINED SUCCESSFULLY :-)"
