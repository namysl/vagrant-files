#!/bin/bash

run_minikube(){
  minikube start
  minikube addons enable metrics-server
}

run_nginx(){
  kubectl apply -f vagrant-kubernetes-one-node/deployment.yaml
  kubectl apply -f vagrant-kubernetes-one-node/service.yaml
}

run_prometheus(){
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm install prometheus prometheus-community/prometheus
  kubectl expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-np
  kubectl patch svc prometheus-server-np --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":30002}]'
}

run_grafana(){
  helm repo add grafana https://grafana.github.io/helm-charts
  helm install grafana grafana/grafana
  kubectl expose service grafana --type=NodePort --target-port=3000 --name=grafana-np
  kubectl patch svc grafana-np --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":30003}]'
}

run_minikube
run_nginx
run_prometheus
run_grafana

echo "NEXT STEPS - PERFORM MANUALLY:

- ENABLE KUBERNETES DASHBOARD:
minikube dashboard &
kubectl proxy --address='0.0.0.0' --disable-filter=true &

- PORT FORWARD THE SERVICES:
kubectl port-forward service/nginx-kube --address 0.0.0.0 30001:80 &
kubectl port-forward service/prometheus-server-np --address 0.0.0.0 30002:80 &
kubectl port-forward service/grafana-np --address 0.0.0.0 30003:80 &

- GET ACCESS TO GRAFANA:
kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

- ADD DATA SOURCES IN GRAFANA:
URL: http://prometheus-server:80

- IMPORT DASHBOARD IN GRAFANA:
e.g. ID: 1860

- GET URL OF THE SERVICE:
minikube service --url nginx-kube

- OPTIONALLY CHECK LOGS:
kubectl logs deployment/<deployment-name>
kubectl logs service/<service-name>"