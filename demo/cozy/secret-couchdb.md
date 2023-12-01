Secret for testing this app with existing secrets:

```yaml
---
# this secret is for testing only!
apiVersion: v1
kind: Secret
metadata:
  name: couchdb-couchdb
type: opaque
stringData:
  host: couchdb-svc-couchdb
  port: "5984"
  protocol: http
  user: couchadmin
  password: ilovemyfriendstodayandtomorrowandthenextday
  adminUsername: couchadmin
  adminPassword: ilovemyfriendstodayandtomorrowandthenextday
  erlangCookie: kjlfedjfkladshjkghjakslghjklasfhjkldshfjkdlahjkf
```
