#!/bin/bash

echo "Enter the path to your private registry's self-signed CA cert:"
read rootCA

echo "Enter the name of your guest cluster:"
read gcname

echo "Enter the namespace which contains your guest cluster:"
read gcnamespace

[ -z "$rootCA" -o -z "$gcname" -o -z "$gcnamespace" ] && echo "Error: Root CA cert, guest cluster name and guest cluster namespace must not be blank" && exit

workdir="/tmp/$gcnamespace-$gcname"
mkdir -p $workdir
sshkey=$workdir/gc-sshkey # path for gc private key
gckubeconfig=$workdir/kubeconfig # path for gc kubeconfig


# installCA
# @param1: ip of node
# @param2: path to ca cert
installCA() {
node_ip=$1
capath=$2
scp -q -i $sshkey -o StrictHostKeyChecking=no $capath vmware-system-user@$node_ip:/tmp/ca.crt
[ $? == 0 ] && ssh -q -i $sshkey -o StrictHostKeyChecking=no vmware-system-user@$node_ip sudo cp /etc/pki/tls/certs/ca-bundle.crt /etc/pki/tls/certs/ca-bundle.crt_bk

[ $? == 0 ] && ssh -q -i $sshkey -o StrictHostKeyChecking=no vmware-system-user@$node_ip 'sudo cat /etc/pki/tls/certs/ca-bundle.crt_bk /tmp/ca.crt > /tmp/ca-bundle.crt'
[ $? == 0 ] && ssh -q -i $sshkey -o StrictHostKeyChecking=no vmware-system-user@$node_ip sudo mv /tmp/ca-bundle.crt /etc/pki/tls/certs/ca-bundle.crt

# if error occurred, restore ca-bundler.crt_bk
[ $? == 0 ] && ssh -q -i $sshkey -o StrictHostKeyChecking=no vmware-system-user@$node_ip sudo systemctl restart docker.service
}


# get guest cluster private key for each node
kubectl get secret -n $gcnamespace $gcname"-ssh" -o jsonpath='{.data.ssh-privatekey}' | base64 --decode > $sshkey
[ $? != 0 ] && echo " please check existence of guest cluster private key secret" && exit
chmod 600 $sshkey

#get guest cluster kubeconfig
kubectl get secret -n $gcnamespace $gcname"-kubeconfig" -o jsonpath='{.data.value}' | base64 --decode > $gckubeconfig
[ $? != 0 ] && echo " please check existence of guest cluster private key secret" && exit

# get IPs of each guest cluster nodes
iplist=$(KUBECONFIG=$gckubeconfig kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}')
for ip in $iplist
do
echo "installing root ca into node $ip (needs about 10 seconds)... "
installCA $ip $rootCA && echo "Successfully installed root ca into node $ip" || echo "Failed to install root ca into node $ip"
done
