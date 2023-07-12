# Kubevirt Disks

These files are the declarative way to pre-seed disk images onto a node. They used the CDI HTTP import process which is mush slower than a direct upload (I really need to open a ticket about it). 
They additionally force their volumes to bind without waiting for first consumer, but that should be removed when using these in a multi-node setup.

## Debian12 Cloud Image

```bash
export VOLUME_NAME=debian12-pvc
export NAMESPACE="default"
export IMAGE_URL="https://cloud.debian.org/images/cloud/bookworm/daily/latest/debian-12-generic-amd64-daily.qcow2"
export IMAGE_PATH=debian-12-generic-amd64-daily.qcow2
export VOLUME_TYPE=pvc
export SIZE=120Gi
export PROXY_ADDRESS=$(kubectl get svc cdi-uploadproxy-loadbalancer -n cdi -o json | jq --raw-output '.spec.clusterIP')
# $(kubectl get svc cdi-uploadproxy -n cdi -o json | jq --raw-output 

wget -O $IMAGE_PATH $IMAGE_URL

virtctl image-upload $VOLUME_TYPE $VOLUME_NAME \
    --size=$SIZE \
    --image-path=$IMAGE_PATH \
    --uploadproxy-url=https://$PROXY_ADDRESS:443 \
    --namespace=$NAMESPACE \
    --insecure --force-bind
```

## Ubuntu 20.04 Cloud Image

```bash
export VOLUME_NAME=focal-pvc
export NAMESPACE="default"
export IMAGE_URL="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
export IMAGE_PATH=focal-server-cloudimg-amd64.img
export VOLUME_TYPE=pvc
export SIZE=120Gi
export PROXY_ADDRESS=$(kubectl get svc cdi-uploadproxy-loadbalancer -n cdi -o json | jq --raw-output '.spec.clusterIP')
# $(kubectl get svc cdi-uploadproxy -n cdi -o json | jq --raw-output 

wget -O $IMAGE_PATH $IMAGE_URL

virtctl image-upload $VOLUME_TYPE $VOLUME_NAME \
    --size=$SIZE \
    --image-path=$IMAGE_PATH \
    --uploadproxy-url=https://$PROXY_ADDRESS:443 \
    --namespace=$NAMESPACE \
    --insecure --force-bind
```

## Ubuntu 22.04 Cloud Image

```bash
export VOLUME_NAME=jammy-pvc
export NAMESPACE="default"
export IMAGE_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
export IMAGE_PATH=jammy-server-cloudimg-amd64.img
export VOLUME_TYPE=pvc
export SIZE=120Gi
export PROXY_ADDRESS=$(kubectl get svc cdi-uploadproxy-loadbalancer -n cdi -o json | jq --raw-output '.spec.clusterIP')
# $(kubectl get svc cdi-uploadproxy -n cdi -o json | jq --raw-output 

wget -O $IMAGE_PATH $IMAGE_URL

virtctl image-upload $VOLUME_TYPE $VOLUME_NAME \
    --size=$SIZE \
    --image-path=$IMAGE_PATH \
    --uploadproxy-url=https://$PROXY_ADDRESS:443 \
    --namespace=$NAMESPACE \
    --insecure --force-bind
```

## Ubuntu 23.04 Cloud Image

```bash
export VOLUME_NAME=lunar-pvc
export NAMESPACE="default"
export IMAGE_URL="https://cloud-images.ubuntu.com/lunar/current/lunar-server-cloudimg-amd64.img"
export IMAGE_PATH=lunar-server-cloudimg-amd64.img
export VOLUME_TYPE=pvc
export SIZE=120Gi
export PROXY_ADDRESS=$(kubectl get svc cdi-uploadproxy-loadbalancer -n cdi -o json | jq --raw-output '.spec.clusterIP')
# $(kubectl get svc cdi-uploadproxy -n cdi -o json | jq --raw-output 

wget -O $IMAGE_PATH $IMAGE_URL

virtctl image-upload $VOLUME_TYPE $VOLUME_NAME \
    --size=$SIZE \
    --image-path=$IMAGE_PATH \
    --uploadproxy-url=https://$PROXY_ADDRESS:443 \
    --namespace=$NAMESPACE \
    --insecure --force-bind
```

## Windows10 ISO

```bash
export VOLUME_NAME="windows10-iso-pvc"
export NAMESPACE="default"
export IMAGE_URL="https://www.itechtics.com/?dl_id=173"
export IMAGE_PATH="Win10_22H2_EnglishInternational_x64.iso"
export VOLUME_TYPE="pvc"
export SIZE="8Gi"
export PROXY_ADDRESS=$(kubectl get svc cdi-uploadproxy-loadbalancer -n cdi -o json | jq --raw-output '.spec.clusterIP')
# $(kubectl get svc cdi-uploadproxy -n cdi -o json | jq --raw-output 

wget -O $IMAGE_PATH $IMAGE_URL

virtctl image-upload $VOLUME_TYPE $VOLUME_NAME \
    --size=$SIZE \
    --image-path=$IMAGE_PATH \
    --uploadproxy-url=https://$PROXY_ADDRESS:443 \
    --namespace=$NAMESPACE \
    --insecure --force-bind
```

## Windows11 ISO

```bash
export VOLUME_NAME="windows11-iso-pvc"
export NAMESPACE="default"
export IMAGE_URL="https://www.itechtics.com/?dl_id=168"
export IMAGE_PATH="Win11_22H2_English_x64.iso"
export VOLUME_TYPE="pvc"
export SIZE="8Gi"
export PROXY_ADDRESS=$(kubectl get svc cdi-uploadproxy-loadbalancer -n cdi -o json | jq --raw-output '.spec.clusterIP')
# $(kubectl get svc cdi-uploadproxy -n cdi -o json | jq --raw-output 

wget -O $IMAGE_PATH $IMAGE_URL

virtctl image-upload $VOLUME_TYPE $VOLUME_NAME \
    --size=$SIZE \
    --image-path=$IMAGE_PATH \
    --uploadproxy-url=https://$PROXY_ADDRESS:443 \
    --namespace=$NAMESPACE \
    --insecure --force-bind
```

## Debian12 ISO

```bash
export VOLUME_NAME="debian12-iso-pvc"
export NAMESPACE="default"
export IMAGE_URL="https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-12.0.0-amd64-DVD-1.iso"
export IMAGE_PATH="debian-12.0.0-amd64-DVD-1.iso"
export VOLUME_TYPE="pvc"
export SIZE="8Gi"
export PROXY_ADDRESS=$(kubectl get svc cdi-uploadproxy-loadbalancer -n cdi -o json | jq --raw-output '.spec.clusterIP')
# $(kubectl get svc cdi-uploadproxy -n cdi -o json | jq --raw-output 

wget -O $IMAGE_PATH $IMAGE_URL

virtctl image-upload $VOLUME_TYPE $VOLUME_NAME \
    --size=$SIZE \
    --image-path=$IMAGE_PATH \
    --uploadproxy-url=https://$PROXY_ADDRESS:443 \
    --namespace=$NAMESPACE \
    --insecure --force-bind
```
