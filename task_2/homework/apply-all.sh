#!/usr/bin/bash


kubectl apply -n nginx-ingress-hw -f web-deploy-task2-v1.yaml
kubectl apply -n nginx-ingress-hw -f web-deploy-task2-v2.yaml

kubectl apply -n nginx-ingress-hw -f web-cm-task2-v1.yaml
kubectl apply -n nginx-ingress-hw -f web-cm-task2-v2.yaml

kubectl apply -n nginx-ingress-hw -f web-svc-task2-v1.yaml
kubectl apply -n nginx-ingress-hw -f web-svc-task2-v2.yaml

sleep 5;

kubectl apply -n nginx-ingress-hw -f web-ingress-task2-v1.yaml # simple ingress

kubectl apply -n nginx-ingress-hw -f web-ingress-task2-canary-v2.yaml # ingress for canary deployment


ALL_COUNT=`kubectl get -n nginx-ingress-hw all | wc -l`

INGRESS_COUNT=`kubectl get -n nginx-ingress-hw ingress | wc -l`

if [[ $ALL_COUNT  == '19' ]] && [[ $INGRESS_COUNT == '3' ]]; then
	echo "All is done!"
fi

