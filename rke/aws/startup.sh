#!/bin/bash

sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
sudo apt install -y docker-ce-cli=5:19.03.14~3-0~ubuntu-bionic docker-ce=5:19.03.14~3-0~ubuntu-bionic
sudo usermod -aG docker ubuntu
sudo systemctl restart docker