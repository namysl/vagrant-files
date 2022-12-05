#!/bin/bash

helm install prometheus prometheus-community/prometheus
kubectl expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-np
kubectl patch svc prometheus-server-np --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":30002}]'

helm install grafana grafana/grafana
kubectl expose service grafana --type=NodePort --target-port=3000 --name=grafana-np
kubectl patch svc grafana-np --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":30003}]'

minikube dashboard &
kubectl proxy --address='0.0.0.0' --disable-filter=true &

kubectl port-forward service/nginx-on-minikube --address 0.0.0.0 30001:80 &
kubectl port-forward service/prometheus-server-ng --address 0.0.0.0 30002:80 &
kubectl port-forward service/prometheus-server-np --address 0.0.0.0 30002:80 &
kubectl port-forward service/grafana-np --address 0.0.0.0 30002:80 &
kubectl port-forward service/grafana-np --address 0.0.0.0 30003:80 &

kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo