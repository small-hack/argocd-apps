# Kubevirt

Kubevirt wraps QEMU and provides a Kubernetes-Native way to deploy virtual machines as code.

- Virtual Machines are defined as yaml in the `virtual-machines` directory
- Disk images are stores as PVCs and are defined in the `disks` directory

## Installing the Operator and CRDs

Following: https://kubevirt.io/quickstart_cloud/

> You can manually download assets by checking the releases links: https://github.com/kubevirt/kubevirt/releases/

- Installing the cli from source

  ```bash
  VERSION=$(kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.observedKubeVirtVersion}")
  ARCH=$(uname -s | tr A-Z a-z)-$(uname -m | sed 's/x86_64/amd64/') || windows-amd64.exe
  echo ${ARCH}
  curl -L -o virtctl https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/virtctl-${VERSION}-${ARCH}
  chmod +x virtctl
  sudo install virtctl /usr/local/bin
  ```

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
