---
# First sync wave done in parallel with creating secrets. Must be BEFORE
# netmaker so that netmaker persists it's data between upgrades. Sync policy
# is set to ApplyOutOfSyncOnly=true to create the volume initially only.
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: netmaker-persistence
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  project: default
  destination:
    server: "https://kubernetes.default.svc"
    namespace: netmaker
  source:
    repoURL: https://github.com/small-hack/argocd-apps.git
    path: demo/netmaker/manifests/persistence/
  syncPolicy:
    syncOptions:
      - ApplyOutOfSyncOnly=true
    automated:
      selfHeal: true

