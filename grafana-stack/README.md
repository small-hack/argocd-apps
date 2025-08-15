### 🚧 This is under construction 🚧

## Grafana Monitoring Stack

| Application | Description |
|-------------|-------------|
| alloy       | collects logs and metrics on each cluster |
| loki        | receives logs and aggregates them before pushing to S3 |
| mimir       | prometheus replacement that does s3 storage (collects metrics) |
| grafana     | metics and logs query frontend and dashboards |

## Loki

like Prometheus, but for logs

- Loki is a horizontally-scalable, highly-available, multi-tenant log aggregation system inspired by Prometheus.
- It is designed to be very cost effective and easy to operate.
- It does not index the contents of the logs, but rather a set of labels for each log stream.

See: https://github.com/grafana/loki

## Coming soon

Soon you'll also be able to use [smol-k8s-lab](https://github.com/small-hack/smol-k8s-lab) to deploy this.
