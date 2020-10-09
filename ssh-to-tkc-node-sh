echo "Enter the supervisor cluster namespace in which the TKC cluster was built:"
read gcnamespace

echo "Enter the name of the target workload cluster:"
read gcname

gcname=devops-cluster-1
gcnamespace=devops
workdir="/tmp/$gcnamespace-$gcname"
mkdir -p $workdir
sshkey=$workdir/gc-sshkey # path for gc private key
gckubeconfig=$workdir/kubeconfig # path for gc kubeconfig
kubectl get secret -n $gcnamespace $gcname"-ssh" -o jsonpath='{.data.ssh-privatekey}' | base64 --decode > $sshkey
chmod 600 $sshkey
kubectl get secret -n $gcnamespace $gcname"-kubeconfig" -o jsonpath='{.data.value}' | base64 --decode > $gckubeconfig
#
echo "Enter the target IP address of the TKC node"
read tkcip
ssh -q -i $sshkey -o StrictHostKeyChecking=no vmware-system-user@$tkcip
