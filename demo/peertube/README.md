# Peertube

This directory contains the resources to deploy [Peertube](https://joinpeertube.org/en_US), a tool for sharing online videos developed by the french non-profit Framasoft.
We deploy it using our standard Cloud-Native Postgres, Valkey, and SeaweedFS appsets.

<img width="1141" alt="Screenshot 2024-12-28 at 13 35 23" src="https://github.com/user-attachments/assets/2c501b40-08b6-4267-9c20-c4f09909da90" />

## ToDo

- Convert secrets from manifests to external secrets
- Remove hard-coded strings that should be provided from the appset-secret-plugin instead
- Find and add monitoring resources like dashboards for grafana
