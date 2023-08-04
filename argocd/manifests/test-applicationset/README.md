# So I have an idea

![](https://media.giphy.com/media/ojpU1QtYzaVDa/giphy.gif)


```bash
export HOSTNAME="www.hats4dogs.biz"
export NAMESPACE="vouch"
export ENVIRONMENT="prod"

yq -i '.spec.generators[].list.elements[0].hostname = env(HOSTNAME)' vouch.yaml
yq -i '.spec.generators[].list.elements[0].namespace = env(NAMESPACE)' vouch.yaml
yq -i '.spec.generators[].list.elements[0].environment = env(ENVIRONMENT)' vouch.yaml

kubectl apply -f vouch.yaml -n argocd
```
