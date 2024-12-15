#!/usr/bin/env bash
# tiny script to bump the version of the prometheus CRDs to match the helm chart version

set -euo pipefail

new_version="$1"

version=$(grep "targetRevision:" "./prometheus/crds/prometheus_crds_argocd_app.yaml" | awk '{print $2}' | tr -d "kube-prometheus-stack-")

# this shouldn't happen
if [[ ! $version ]]; then
  echo "No valid version was found"
  exit 1
fi

echo "Bumping version for promtheus CRDs from $version to $new_version to be in line with the helm chart version"
sed -i "s/${version}/${new_version}/" "./prometheus/crds/prometheus_crds_argocd_app.yaml"
