# Virtual Machines

These files assume the presence of a PVC containing the disk-image they will boot from. You can deploy those declaratively via the HTTP importer or manually upload your dick image to the node as documented below.

## Debian 12 Cloud-Image Example

Cloud-images are booted directly from the PVC, so it needs to be the size of a full disk

```bash
export VOLUME_NAME="debian12-pvc"
export NAMESPACE="debian12"
export IMAGE_PATH="debian-12-generic-amd64-daily.qcow2"
export VOLUME_TYPE="pvc"
export SIZE="120Gi"
export PROXY_ADDRESS=$(kubectl get svc cdi-uploadproxy-loadbalancer -n cdi -o json | jq --raw-output '.spec.clusterIP')
# $(kubectl get svc cdi-uploadproxy -n cdi -o json | jq --raw-output 

virtctl image-upload $VOLUME_TYPE $VOLUME_NAME \
    --size=$SIZE \
    --image-path=$IMAGE_PATH \
    --uploadproxy-url=https://$PROXY_ADDRESS:443 \
    --namespace=$NAMESPACE \
    --insecure --force-bind
```

## Windows 10 ISO Example

ISO files can boot into an installer process which will setup the OS on a secondary drive, so the ISO PVC doesnt need to be any bigger than the ISO image itself.

```bash
export VOLUME_NAME="windows10-pvc"
export NAMESPACE="windows10"
export IMAGE_PATH="Win10_22H2_EnglishInternational_x64.iso"
export VOLUME_TYPE="pvc"
export SIZE="8Gi"
export PROXY_ADDRESS=$(kubectl get svc cdi-uploadproxy-loadbalancer -n cdi -o json | jq --raw-output '.spec.clusterIP')
# $(kubectl get svc cdi-uploadproxy -n cdi -o json | jq --raw-output 

virtctl image-upload $VOLUME_TYPE $VOLUME_NAME \
    --size=$SIZE \
    --image-path=$IMAGE_PATH \
    --uploadproxy-url=https://$PROXY_ADDRESS:443 \
    --namespace=$NAMESPACE \
    --insecure --force-bind
```
