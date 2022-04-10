1. Create users deploy_view and deploy_edit. Give the user deploy_view rights only to view deployments, pods. Give the user deploy_edit full rights to the objects deployments, pods:

#### Create deploy_view user:

```
kubectl auth can-i create deployments --namespace default

Create private key
openssl genrsa -out deploy_view.key 2048

Create a certificate signing request
openssl req -new -key deploy_view.key -out deploy_view.csr -subj "/CN=deploy_view"

openssl x509 -req -in deploy_view.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out deploy_view.crt -days 365

Create user in kubernetes
kubectl config set-credentials deploy_view --client-certificate=./certs/deplov_view.crt --client-key=./certs/deplov_view.key

Set context for user

kubectl config set-context deploy_view --cluster=minikube --user=deploy_view

Edit ~/.kube/config:

sudo vim ~/.kube/config

users:
- name: deploy_view
  user:
    client-certificate: /home/natig2992/education/task_4/homework/certs/deploy_view.crt
    client-key: /home/natig2992/education/task_4/homework/certs/deploy_view.key


Switch to default(admin) context
kubectl config use-context minikube


kubectl apply -f deploy_view.yaml
clusterrole.rbac.authorization.k8s.io/only-view-cluster unchanged
clusterrolebinding.rbac.authorization.k8s.io/deploy_view created
```
#### Create deploy_edit user:

```
kubectl auth can-i create deployments --namespace default

Create private key
openssl genrsa -out deploy_edit.key 2048

Create a certificate signing request
openssl req -new -key deploy_edit.key -out deploy_edit.csr -subj "/CN=deploy_edit"

openssl x509 -req -in deploy_edit.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out deploy_edit.crt -days 365

Create user in kubernetes
kubectl config set-credentials deploy_edit --client-certificate=./certs/deploy_edit.crt --client-key=./certs/deploy_edit.key

Set context for user

kubectl config set-context deploy_edit --cluster=minikube --user=deploy_edit

Edit ~/.kube/config:

sudo vim ~/.kube/config

users:
- name: deploy_edit
  user:
    client-certificate: /home/natig2992/education/task_4/homework/certs/deploy_edit.crt
    client-key: /home/natig2992/education/task_4/homework/certs/deploy_edit.key


Switch to default(admin) context
kubectl config use-context minikube


kubectl apply -f deploy_edit.yaml
clusterrole.rbac.authorization.k8s.io/edit-cluster unchanged
clusterrolebinding.rbac.authorization.k8s.io/deploy_edit created

kubectl config use-context deploy_edit

Check:

kubectl get po

kubectl get deploy

```

2. Create namespace prod. Create users prod_admin, prod_view. Give the user prod_admin admin rights on ns prod, give the user prod_view only view rights on namespace prod:

```
kubectl create ns prod
namespace/prod created
```
#### See prod_admin.yaml and prod_view.yaml files

##### Create user "prod_admin"
```
kubectl auth can-i create deployments --namespace prod

Create private key
openssl genrsa -out prod_admin.key 2048

Create a certificate signing request
openssl req -new -key prod_admin.key -out prod_admin.csr -subj "/CN=prod_admin"

openssl x509 -req -in prod_admin.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out prod_admin.crt -days 365

Create user in kubernetes
kubectl config set-credentials prod_admin --client-certificate=./certs/prod_admin.crt --client-key=./certs/prod_admin.key

Set context for user

kubectl config set-context prod_admin --cluster=minikube --user=prod_admin

Edit ~/.kube/config:

sudo vim ~/.kube/config

user:
- name: prod_admin
  user:
    client-certificate: /home/natig2992/education/task_4/homework/certs/prod_admin.crt
    client-key: /home/natig2992/education/task_4/homework/certs/prod_admin.key



Switch to default(admin) context
kubectl config use-context minikube


kubectl apply -f prod_admin.yaml
role.rbac.authorization.k8s.io/admin-role created
rolebinding.rbac.authorization.k8s.io/prod_admin created

kubectl config use-context prod_admin

Check:

# First let`s create deployment with two pods:
kubectl apply -f /home/natig2992/education/task_1/nginx-depl.yaml --namespace prod
deployment.apps/nginx-deployment created

# Check created deployment:
kubectl get deploy --namespace prod
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   2/2     2            2           43s

```

##### Create user "prod_view":

```
kubectl auth can-i create deployments --namespace prod

Create private key
openssl genrsa -out prod_view.key 2048

Create a certificate signing request
openssl req -new -key prod_view.key -out prod_view.csr -subj "/CN=prod_view"

openssl x509 -req -in prod_view.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out prod_view.crt -days 365

Create user in kubernetes
kubectl config set-credentials prod_view --client-certificate=./certs/prod_view.crt --client-key=./certs/prod_view.key

Set context for user

kubectl config set-context prod_view --cluster=minikube --user=prod_view

Edit ~/.kube/config:

sudo vim ~/.kube/config

user:
- name: prod_view
  user:
    client-certificate: /home/natig2992/education/task_4/homework/certs/prod_view.crt
    client-key: /home/natig2992/education/task_4/homework/certs/prod_view.key


kubectl config use-context prod_view

Switch to default(admin) context
kubectl config use-context minikube


kubectl apply -f prod_view.yaml
role.rbac.authorization.k8s.io/only-view-prod created
rolebinding.rbac.authorization.k8s.io/prod_view created



kubectl config use-context prod_view

Check:
kubectl get deploy --namespace prod
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   2/2     2            2           35m

kubectl get po --namespace prod
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-8d4568bbc-7bmss   1/1     Running   0          35m
nginx-deployment-8d4568bbc-r6xfh   1/1     Running   0          35m

kubectl delete deploy nginx-deployment --namespace prod
Error from server (Forbidden): deployments.apps "nginx-deployment" is forbidden: User "prod_view" cannot delete resource "deployments" in API group "apps" in the namespace "prod"
```


3. Create a serviceAccount sa-namespace-admin. Grant full rights to namespace default. Create context, authorize using the created sa, check accesses:

```
vim sa-admin-ns.yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: sa-namespace-admin
  namespace: default

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  namespace: default
  name: sa-namespace-admin
  labels:
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
subjects:
- kind: ServiceAccount
  name: sa-namespace-admin
roleRef:
  kind: ClusterRole
  name: admin
  apiGroup: rbac.authorization.k8s.io


kubectl apply -f sa-admin-ns.yaml
serviceaccount/sa-namespace-admin created
rolebinding.rbac.authorization.k8s.io/sa-namespace-admin created

# export TOKENNAME and TOKEN via env variables:

export TOKENNAME=$(kubectl get serviceaccount/sa-namespace-admin -o jsonpath='{.secrets[0].name}')
export TOKEN=$(kubectl get secret $TOKENNAME -o jsonpath='{.data.token}' | base64 --decode)

# Check via curl performance:

curl -k -H "Authorization: Bearer $TOKEN" -X GET "https://192.168.59.101:8443/api/v1/nodes" 


# Add serviceAccount in kubecconfig:

kubectl config set-credentials sa-namespace-admin --token=$TOKEN
User "sa-namespace-admin" set.

# Set to sa-namespace-admin context:
kubectl config set-context --current --user=sa-namespace-admin
```
