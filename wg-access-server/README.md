# wireguard access server argo CD app
Using [freifunkMUC/wg-access-server-chart](https://github.com/freifunkMUC/wg-access-server-chart/tree/main/charts/wg-access-server) (which is a fork of [Place1/wg-access-server](https://github.com/Place1/wg-access-server/tree/master/deploy/helm/wg-access-server)) we create a Wireguard based VPN server in k8s.


## Create a wireguard keypair

- install wireguard

  ```bash
  sudo apt-get install wireguard
  ```

- create a key-pair

  ```bash
  wg genkey | tee privatekey | wg pubkey > publickey
  ```
