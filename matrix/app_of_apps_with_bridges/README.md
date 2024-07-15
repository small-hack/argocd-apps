This is an example matrix ArgoCD app of apps, which matches the other matrix app of apps, however this one includes bridges:

- [hookshot bridge](https://matrix-org.github.io/matrix-hookshot/latest/metrics.html) for feeds and github alerts
- [discord bridge](https://docs.mau.fi/bridges/general/docker-setup.html?bridge=discord) for bridging discord with matrix
- [alertmanager](https://github.com/small-hack/matrix-alertmanager) for bridging prometheus with matrix


## Tips

### Listing rooms

Using the [admin api](https://element-hq.github.io/synapse/latest/usage/administration/admin_api/), you'll want to connect to a synapse container and then you can you run the [list rooms query](https://matrix-org.github.io/synapse/v1.40/admin_api/rooms.html#list-room-api):

```bash
# access token can be gotten from Element > Settings > Help & About > Advanced > Access Token
curl --header "Authorization: Bearer <access token here>" http://localhost:8008/_synapse/admin/v1/rooms
```
