#dynamically create PVs with Azure disk for use by a single pod in an AKS cluster

#The following PVC uses managed-csi - Azure Standard SSD locally redundant storage (LRS) to create a managed disk.
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/pvc-azuredisk-csi.yaml

#The following nginx pod creates the PVC using pvc-azuredisk claim
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/nginx-pod-azuredisk.yaml

#Create file and check to see if its been persisted
kubectl exec nginx-azuredisk -- touch /mnt/azuredisk/test.txt
kubectl exec nginx-azuredisk -- ls /mnt/azuredisk
