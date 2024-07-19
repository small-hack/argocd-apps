This is an example matrix ArgoCD app of apps, which matches the other matrix app of apps, however this one includes bridges:

- [discord bridge](https://docs.mau.fi/bridges/general/docker-setup.html?bridge=discord) for bridging discord with matrix
- [alertmanager](https://github.com/small-hack/matrix-alertmanager) for bridging prometheus with matrix
- [rss](https://github.com/small-hack/matrix-rss-bot) for bridging rss feeds into various rooms


## Tips

### Listing rooms

Using the [admin api](https://element-hq.github.io/synapse/latest/usage/administration/admin_api/), you'll want to connect to a synapse container and then you can you run the [list rooms query](https://matrix-org.github.io/synapse/v1.40/admin_api/rooms.html#list-room-api):

```bash
# access token can be gotten from Element > Settings > Help & About > Advanced > Access Token
curl --header "Authorization: Bearer <access token here>" http://localhost:8008/_synapse/admin/v1/rooms
```

### Deleting rooms
Sometimes a room gets weird and you have to delete it. You can only do that by room ID, and you have to escape the `!`:

```bash
# room id can be found in Element > click room > Settings > Advanced
curl --header "Authorization: Bearer <access token here>" \
     --header "Content-Type: application/json" \
     --data '{}' \
     --request DELETE \
     http://localhost:8008/_synapse/admin/v1/rooms/\!84fa89phdafjk:matrix.mydomain.com
```
