# testing
Run the image with an env vars for vouch/http token and port mappings:

```bash
docker run -e "VOUCH_HOSTNAME=vouch" \
           -e "TOKEN=hufdklasbvuipab495r3fahj" \
           -p 4355:4355 \
           jessebot/argocd-env-var-generator-plugin:0.0.1
```

test the endpoint:

```bash
curl http://localhost:4355/api/v1/getparams.execute -H "Authorization: Bearer hufdklasbvuipab495r3fahj" -d '{
  "applicationSetName": "fake-appset",
  "input": {
    "parameters": {
      "param1": "value1"
    }
  }
}'
```

and it should return:

```json
"output": {"parameters": [{"vouch_hostname": "vouch"}]}}
```
