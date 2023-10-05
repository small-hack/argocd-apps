# Kubevirt

Kubevirt wraps QEMU and provides a Kubernetes-Native way to deploy virtual machines as code.

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
 
- Install as a krew plugin

  ```bash
  kubectl krew install virt
  ```

- Enable nested virtualization if desired

  ```bash
  kubectl -n kubevirt patch kubevirt kubevirt \
    --type=merge \
    --patch '{"spec":{"configuration":{"developerConfiguration":{"useEmulation":true}}}}'
  ```
- Find latest CDI asset versions

  ```bash
  export VERSION=$(basename $(curl -s -w %{redirect_url} https://github.com/kubevirt/containerized-data-importer/releases/latest))
  wget https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-operator.yaml
  wget https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-cr.yaml
  ```

## Using the CDI to manage images

- https://kubevirt.io/2018/containerized-data-importer.html

## Metrics

- https://kubevirt.io/user-guide/operations/component_monitoring/
- use the `prometheus-helm-chart-kube-prometheus` service account created by kube-prometheus-stack
- dashboard: https://grafana.com/grafana/dashboards/11748-kubevirt/
