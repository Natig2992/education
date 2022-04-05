In Minikube in namespace kube-system, there are many different pods running. Your task is to figure out who creates them, and who makes sure they are running (restores them after deletion):

Answer: kubelet service

UID:

`uid: 11b78b01-501f-4a8d-8ec5-f0b053712a43`

Also, please look at screen "Answer_1 for task_2.png" in this repo...
---

### ANSWER2:
1. Create separate namespace for homework-task-2:

`kubectl create ns nginx-ingress-hw`

2. Create and deploy two web deployments **web-deploy-task2-v1.yaml** and **web-deploy-task2-v2.yaml**:

```
kubectl apply -n nginx-ingress-hw -f web-deploy-task2-v1.yaml

kubectl apply -n nginx-ingress-hw -f web-deploy-task2-v2.yaml

```

3. Also we create and deploy two svc(services) and two cm (configmaps):

```
kubectl apply -n nginx-ingress-hw -f web-cm-task2-v1.yaml
kubectl apply -n nginx-ingress-hw -f web-cm-task2-v2.yaml

kubectl apply -n nginx-ingress-hw -f web-svc-task2-v1.yaml
kubectl apply -n nginx-ingress-hw -f web-svc-task2-v2.yaml
```

4. Create and deploy two ingress: simple ingress and ingress for canary deployment:

```
kubectl apply -n nginx-ingress-hw -f web-ingress-task2-v1.yaml # simple ingress

kubectl apply -n nginx-ingress-hw -f web-ingress-task2-canary-v2.yaml # ingress for canary deployment

```

5. Script apply.sh for creating all resorces:

```
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

```

6. GET request by curl tool with different values for **canary** header:

`for i in $(seq 1 100); do curl -H 'canary:never' http://$(minikube ip); done` # No request to CANARY deploy

`for i in $(seq 1 100); do curl -H 'canary:balance' http://$(minikube ip); done` # Partial request 50/50

`for i in $(seq 1 100); do curl -H 'canary:always' http://$(minikube ip); done` # Request only to CANARY deploy


7. Delete all resources and ingress:

`kubectl delete all --all -n nginx-ingress-hw`
`kubectl delete ingress --all -n nginx-ingress-hw`
