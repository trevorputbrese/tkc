#!/bin/bash
echo Enter "S" to login to the Supervisor cluster, "W" to login to a workload cluster, or "R" to login to the same cluster you did last time:
read CLUSTERCHOICE
if [ $CLUSTERCHOICE == "S" ]
then
  echo Please enter the supervisor namespace to which you are trying to login:
  read SUPNS
  echo Please enter your username:
  read USER1
  echo kubectl vsphere login --vsphere-username $USER1 --server=https://10.10.50.11 --tanzu-kubernetes-cluster-namespace $SUPNS --insecure-skip-tls-verify
  login_string="kubectl vsphere login --vsphere-username $USER1 --server=https://10.10.50.11 --tanzu-kubernetes-cluster-namespace $SUPNS --insecure-skip-tls-verify"
  temp_file=$"/users/tputbrese/temp/klogin.txt"
  echo "$login_string" >"$temp_file"
  kubectl vsphere login --vsphere-username $USER1 --server=https://10.10.50.11 --tanzu-kubernetes-cluster-namespace $SUPNS --insecure-skip-tls-verify
elif [ $CLUSTERCHOICE == "W" ]
then
  echo Please enter the name of the supervisor namespace in which the workload cluster resides:
  read SUPNS1
  echo Please enter the name of the workload cluster to which you are trying to login:
  read WKLD
  echo Please enter your username:
  read USER2
  echo kubectl vsphere login --vsphere-username $USER2 --server=https://10.10.50.11 --tanzu-kubernetes-cluster-namespace $SUPNS1 --tanzu-kubernetes-cluster-name $WKLD --insecure-skip-tls-verify
  login_string="kubectl vsphere login --vsphere-username $USER2 --server=https://10.10.50.11 --tanzu-kubernetes-cluster-namespace $SUPNS1 --insecure-skip-tls-verify"
  temp_file=$"/users/tputbrese/temp/klogin.txt"
  echo "$login_string" >"$temp_file"
  kubectl vsphere login --vsphere-username $USER2 --server=https://10.10.50.11 --tanzu-kubernetes-cluster-namespace $SUPNS1 --tanzu-kubernetes-cluster-name $WKLD --insecure-skip-tls-verify
elif [ $CLUSTERCHOICE == "R" ]
then
  login_string=$(cat /users/tputbrese/temp/klogin.txt)
  echo $login_string
  $login_string
else
  echo "Invalid Option.  Please try logging in again."
fi