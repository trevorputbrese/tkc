#!/bin/bash
rootCA=~/temp/harbor.trvcloud.com.crt
gcname=build-svc-cluster
gcnamespace=shared-svcs-ns
[ -z "$rootCA" -o -z "$gcname" -o -z "$gcnamespace" ] && echo "Please populate rootCA/gcname/gcnamespace variable" && exit
workdir="/tmp/$gcnamespace-$gcname"
mkdir -p $workdir
sshkey=$workdir/gc-sshkey # path for gc private key
gckubeconfig=$workdir/kubeconfig # path for gc kubeconfig
# @param1: ip
# @param2: ca

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
