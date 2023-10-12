# Kubevirt

Kubevirt wraps QEMU and provides a Kubernetes-Native way to deploy virtual machines as code.

## Check host features

- Install libvirt-clients

  ```bash
  sudo apt-get install -y libvirt-clients
  ```

- Check host config

  ```bash
  virt-host-validate qemu
  QEMU: Checking for hardware virtualization                                 : PASS
  QEMU: Checking if device /dev/kvm exists                                   : PASS
  QEMU: Checking if device /dev/kvm is accessible                            : PASS
  QEMU: Checking if device /dev/vhost-net exists                             : PASS
  QEMU: Checking if device /dev/net/tun exists                               : PASS
  ```

## Install virtctl

- Install from github

    ```bash
    export VERSION=v0.41.0
    wget https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/virtctl-${VERSION}-linux-amd64
    ```

- Install as a krew plugin

  ```bash
  kubectl krew install virt
  ```

## Software Emulation / Nested virtualization

Enable nested virtualization if desired

  ```bash
  kubectl -n kubevirt patch kubevirt kubevirt \
    --type=merge \
    --patch '{"spec":{"configuration":{"developerConfiguration":{"useEmulation":true}}}}'
  ```
## Uninstalling

```bash
export RELEASE=v0.17.0

# --wait=true should anyway be default
kubectl delete -n kubevirt kubevirt kubevirt --wait=true 

# this needs to be deleted to avoid stuck terminating namespaces
kubectl delete apiservices v1.subresources.kubevirt.io 

# not blocking but would be left over
kubectl delete mutatingwebhookconfigurations virt-api-mutator 

# not blocking but would be left over
kubectl delete validatingwebhookconfigurations virt-operator-validator 

# not blocking but would be left over
kubectl delete validatingwebhookconfigurations virt-api-validator 

kubectl delete -f https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-operator.yaml --wait=false
```

## Using the CDI to manage images

- https://kubevirt.io/2018/containerized-data-importer.html

## Metrics

- https://kubevirt.io/user-guide/operations/component_monitoring/
- use the `prometheus-helm-chart-kube-prometheus` service account created by kube-prometheus-stack
- dashboard: https://grafana.com/grafana/dashboards/11748-kubevirt/
