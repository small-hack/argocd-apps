# Whats all this then?

This is a Docker container that will take env vars and spit them back out as json.

Input:
```bash
docker run --rm -e "greeting=Howdy Yall" deserializeme/jq-env:latest 
```

Output:
```json
{
  "greeting": "Howdy Yall",
  "_": "/usr/bin/jq"
}
```
