### HOMEWORK TASKS:

1. We published minio "outside" using nodePort. Do the same but using ingress:

```
cat ingress-minio.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minio-ingress
  labels:
    name: minio-ingress
spec:
  rules:
  - http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: minio-def
            port:
              number: 9001

---
apiVersion: v1
kind: Service
metadata:
  name: minio-def
spec:
  selector:
    app: minio
  ports:
  - port: 9001
    targetPort: 9001

kubectl apply -f ingress-minio.yaml
```

2. Publish minio via ingress so that minio by ip_minikube and nginx returning hostname (previous job) by path ip_minikube/web are available at the same time:

```
# From task_2 copy deployment 
cat deployment_service.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: web
  name: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - image: nginx:latest
        name: nginx
        ports:
        - containerPort: 80
        volumeMounts:
          - name: config-nginx
            mountPath: /etc/nginx/conf.d
      volumes:
        - name: config-nginx
          configMap:
            name: nginx-configmap
--------------------------------------------------------
# From task_2 copy cm (ConfigMap)
cat nginx-configmap.yaml
apiVersion: v1
data:
  default.conf: |-
    server {
        listen 80 default_server;
        server_name _;
        default_type text/plain;

        location / {
            return 200 '$hostname\n';
        }
    }
kind: ConfigMap
metadata:
  creationTimestamp: null
  name: nginx-configmap
-----------------------------------------------------
cat ingress-minio-2.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minio-ingress-2
  labels:
    name: minio-ingress-2
spec:
  rules:
  - http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: minio-svc
            port:
              number: 9001
      - pathType: Prefix
        path: "/web"
        backend:
          service:
            name: web-headless
            port:
              number: 80

---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: web
  name: web-headless
spec:
  type: ClusterIP
  clusterIP: None
  selector:
    app: web
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: minio-svc
spec:
  selector:
    app: minio
  ports:
  - port: 9001
    targetPort: 9001

kubectl apply -f nginx-configmap.yaml
kubectl apply -f deployment_service.yaml
kubectl apply -f ingress-minio-2.yaml

kubectl get pods
NAME                    READY   STATUS    RESTARTS   AGE
minio-94fd47554-z44b7   1/1     Running   0          42m
web-6745ffd5c8-86875    1/1     Running   0          6m20s
web-6745ffd5c8-kjp7t    1/1     Running   0          6m20s
web-6745ffd5c8-m7mt5    1/1     Running   0          6m20s

```

3. Create deploy with emptyDir save data to mountPoint emptyDir, delete pods, check data:

```
cat deployEmptyDir.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: deploy-emptydir
  labels:
    app: deploy-emptydir
spec:
  replicas: 3
  selector:
    matchLabels:
      app: deploy-emptydir
  template:
    metadata:
      labels:
        app: deploy-emptydir
    spec:
      containers:
        - name: deploy-emptydir
          image: nginx:1.21
          volumeMounts:
            - mountPath: /tmp/test-dir
              name: test-volume
          ports:
          - containerPort: 80
          resources:
            limits:
              memory: "128Mi"
              cpu: "500m"
          command: ["/bin/sh"]
          args: ["-c", "while true; do date >> /tmp/test-dir/file.txt; sleep 3; done"]
      volumes:
        - name: test-volume
          emptyDir:
            {}

kubectl apply -f deployEmptyDir.yaml

kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
deploy-emptydir-7589b85fbc-llrkt   1/1     Running   0          19s
deploy-emptydir-7589b85fbc-wkntm   1/1     Running   0          19s
deploy-emptydir-7589b85fbc-z2mtg   1/1     Running   0          19s


```
#### Check volume in pod:

```
kubectl exec -it deploy-emptydir-7589b85fbc-llrkt  -- bash
head -n5 /tmp/test-dir/file.txt
Tue Apr  5 22:54:14 UTC 2022
Tue Apr  5 22:54:17 UTC 2022
Tue Apr  5 22:54:20 UTC 2022
Tue Apr  5 22:54:23 UTC 2022
Tue Apr  5 22:54:26 UTC 2022
```
#### Check volume in minikube:

```
minikube ssh
sudo head -n5  /var/lib/kubelet/pods/528fccea-682a-4bb4-9eff-c3b86c3d5e48/volumes/kubernetes.io~empty-dir/test-volume/file.txt
Tue Apr  5 22:54:14 UTC 2022
Tue Apr  5 22:54:17 UTC 2022
Tue Apr  5 22:54:20 UTC 2022
Tue Apr  5 22:54:23 UTC 2022
Tue Apr  5 22:54:26 UTC 2022

# Where "528fccea-682a-4bb4-9eff-c3b86c3d5e48" is my pod UID 
```
##### Let`s check what happens if we delete our deployment(respectively our pods):

```
kubectl delete deploy deploy-emptydir
minikube ssh
sudo head -n5  /var/lib/kubelet/pods/528fccea-682a-4bb4-9eff-c3b86c3d5e48/volumes/kubernetes.io~empty-dir/test-volume/file.txt
head: cannot open '/var/lib/kubelet/pods/528fccea-682a-4bb4-9eff-c3b86c3d5e48/volumes/kubernetes.io~empty-dir/test-volume/file.txt' for reading: No such file or directoryt
```
This is because we delete our deploy with all of the pods and out UID "528fccea-682a-4bb4-9eff-c3b86c3d5e48" our number is no longer valid

4. Optional. Raise an nfs share on a remote machine. Create a pv using this share, create a pvc for it, create a deployment. Save data to the share, delete the deployment, delete the pv/pvc, check that the data is safe:

  1.  Create one pv "pv-nfs" and one pvc "pvc-nfs":

```
kubectl apply -f pv-nfs.yaml
kubectl apply -f pvc-nfs.yaml
```

  2.  Create deployment_service.yaml with new directives:

```
        volumeMounts:
          - name: config-nginx
            mountPath: "/etc/nginx/conf.d"
          - name: nfs-www
            mountPath: "/var/www/html/"
      volumes:
        - name: config-nginx
          configMap:
            name: nginx-configmap
        - name: nfs-www
          persistentVolumeClaim:
            claimName: pvc-nfs
kubectl apply -f deployment_service.yaml
```

  3.  On NFS server we share dir:

```
cat /etc/exports

/opt/nfs4/      *(rw,sync,no_subtree_check,crossmnt,insecure,fsid=0)
/opt/nfs4/backups       *(rw,sync,no_subtree_check,insecure)

```
  4.  All config for NFS mounting in pv-nfs.yaml file

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv-home
  labels:
    app: nfs-pv-app
spec:
  capacity:
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /backups
    server: 10.88.25.83
```

See all screens in repo for proof, that NFS share  is working: 

