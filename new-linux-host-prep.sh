#!/usr/bin/env bash
#
#install open-ssh
sudo apt update
sudo apt upgrade -y
sudo apt install openssh-server -y
sudo systemctl enable ssh
sudo systemctl start ssh
sudo ufw allow ssh
#
#install RDP
sudo apt install xrdp -y
sudo adduser xrdp ssl-cert
sudo systemctl restart xrdp
sudo ufw allow 3389
#
#install docker
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
sudo docker run hello-world
sudo groupadd docker
sudo usermod -aG docker $USER
#
#
#install klogin
cd ~
mkdir temp
cd temp
cat <<EOF > klogin
  
#!/bin/bash
echo Enter "S" to login to the Supervisor cluster or "W" to login to a workload cluster:
read CLUSTERCHOICE
if [ $CLUSTERCHOICE == "S" ]
then
  echo Please enter the supervisor namespace to which you are trying to login:
  read SUPNS
  echo Please enter your username:
  read USER1
  kubectl vsphere login --vsphere-username $USER1 --server=https://60.60.60.10 --tanzu-kubernetes-cluster-namespace $SUPNS --insecure-skip-tls-verify
elif [ $CLUSTERCHOICE == "W" ]
then
  echo Please enter the name of the workload cluster to which you are trying to login:
  read WKLD
  echo Please enter the name of the supervisor namespace in which the workload cluster resides:
  read SUPNS1
  echo Please enter your username:
  read USER2
  kubectl vsphere login --vsphere-username $USER2 --server=https://60.60.60.10 --tanzu-kubernetes-cluster-namespace $SUPNS1 --tanzu-kubernetes-cluster-name $WKLD --insecure-skip-tls-verify
else
  echo "Invalid Option.  Please try logging in again."
fi
EOF
chmod +x klogin
sudo cp ./klogin /usr/bin/klogin
#
#
#install kubectl and kubect vsphere
# wget xxxxx --no-check-certificate
# unzip vsphere-plugin.zip
# cd bin 
#
#
#install krew
#install kubectl auto-completekubectl completion bash |sudo tee /etc/bash_completion.d/kubectl
#


