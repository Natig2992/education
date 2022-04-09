kubectl delete deploy web
sleep 1;

kubectl delete pvc pvc-nfs

sleep 1;

kubectl delete pv nfs-pv-home

