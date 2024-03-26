# Netmaker via Argo CD

[Netmaker](https://github.com/gravitl/netmaker) is a network management solution for creating virtual private networks via Wireguard ®️.

We're currently using our own home grown helm chart as it supports existing secrets and initial super admin user creation:
https://github.com/small-hack/netmaker-helm

![Screenshot of the Argo CD web interface showing the netmaker app of apps. The netmaker app shows three children: netmaker-persistence application in healthy state, netmaker-appset with a child of netmaker-helm app both in healthy state, and the netmaker external secrets appset with a child app of netmaker-externalsecrets also both in a healthy state](./netmaker.png)

![Screenshot of the Argo CD web interface showing the netmaker-helm app's networking view. From the left it shows connection from the internet to the ip 192.168.42.42 which then connects to three ingresses, which connect to three services, which connect to three pods. The ingresses are netmaker-api, netmaker-mqtt, and netmaker-ui, which similarly named services and pods. Outside of that part of the chart are two services netmaker-postgresql and netmaker-postgresql-hl. Both connect to a pod called netmaker-postgresql-0](./netmaker-network.png)

### Sync waves

1. netmaker persistence (PVC for the postgres cluster) and external secrets
2. netmaker helm chart, including the postgresql cluster provided by the bitnami sub chart


#### Installing via smol-k8s-lab

Please see the [smol-k8s-lab docs](https://small-hack.github.io/smol-k8s-lab/k8s_apps/netmaker) for more info.
