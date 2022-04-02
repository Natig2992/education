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

kubectl -n nginx-ingress-hw get all

if [[ $? == '0' ]]; then
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