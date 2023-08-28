#!/usr/bin/env bash
#Author: rangapv@yahoo.com 29-03-23

ray=1
raya=1

inst() {

kcl=`kubectl get nodes`
kcls="$?"

if [[ (( $kcls -ne 0 )) ]]
then
	echo "k8s Cluster Not Ready"
	exit
fi


ray11=`kubectl -n ray-system get pod --selector=app.kubernetes.io/component=kuberay-operator | wc -l`
ray11s="$?"
if [[ ( "$ray11" -gt 0 ) ]]
then
  status "$ray11s" "$ray11"
else
  ray1=`kubectl create -k "github.com/ray-project/kuberay/ray-operator/config/default?ref=v0.4.0&timeout=90s"`
  ray1s="$?"
  ray=0
  status "$ray1s" "$ray1"
fi

ray10=`kubectl get raycluster | wc -l`
ray10s="$?"

if [[ (( $ray10 -gt 0 )) ]]
then
ray=0
raya=0
#status $ray10s $ray10
else 
ray2=`kubectl apply -f https://raw.githubusercontent.com/rangapv/Rayapp/main/rayauto.yaml`
#ray2=`kubectl apply -f https://raw.githubusercontent.com/ray-project/kuberay/master/ray-operator/config/samples/ray-cluster.autoscaler.yaml`
ray2s="$?"
raya=0
status $ray2s $ray2
fi


if [[ (( $ray -eq 0 )) && (( $raya -eq 0 )) ]]
then
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "Printing Ray-Cluster Status"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
ray32=`kubectl get raycluster`
echo "$ray32"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "Printing Ray-Pod Status"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
ray31=`kubectl -n ray-system get pod --selector=app.kubernetes.io/component=kuberay-operator`	
echo "$ray31"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "Printing Ray-AutoScaler Status"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
ray3=`kubectl get pods --selector=ray.io/cluster=raycluster-autoscaler`
echo "$ray3"
ray3s="$?"
fi

}


status() {

st=$1
cmd=$2
if [[ (( $st -eq 0 )) ]]
then
	echo "the command $cmd PASSED"
else
	echo "the command $cmd FAILED"
fi

}


inst
