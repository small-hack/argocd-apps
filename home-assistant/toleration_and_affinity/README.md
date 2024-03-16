# Home Assistant Argo CD App (with extras)

- Sets node affinity (to attract your pod to a node)

- Sets tolerations to allow home assistant to be scheduled on its own isolated node. (Useful if you have bluetooth or USB devices on a specific node)

- Allows ingress with TLS vis a configurable cert-manager ClusterIssuer
