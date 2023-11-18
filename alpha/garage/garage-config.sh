#!/bin/bash
# https://garagehq.deuxfleurs.fr/documentation/quick-start/#creating-a-cluster-layout

# check ALL garage's nodes
# NODE_IDS=$(kubectl exec --stdin --tty -n garage garage-web-app-0 -- ./garage status | tail -n 3 | cut -d ' ' -f 1 | xargs)
NODE_ID=$(kubectl exec --stdin --tty -n garage garage-web-app-0 -- ./garage status | tail -n 1 | cut -d ' ' -f 1)

# assign location and capcity to node
kubectl exec --stdin --tty -n garage garage-web-app-0 -- ./garage layout assign -z dc1 -c 1G $NODE_ID
