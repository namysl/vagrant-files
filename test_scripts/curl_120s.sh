#!/bin/bash

url=$(minikube service --url nginx-kube)
echo "adres serwisu: $url"

while :
do 
  curl -s -S $url > /dev/null
  sleep 120
done
