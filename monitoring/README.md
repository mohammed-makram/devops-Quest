# Monitoring Setup

This directory contains monitoring configurations for Prometheus and Grafana.

## Components

- **ServiceMonitor**: Configures Prometheus to scrape metrics from the voting app services
- **PodMonitor**: Configures Prometheus to monitor individual pods
- **PrometheusRule**: Defines alerting rules for the application
- **Grafana Dashboard**: Pre-configured dashboard for visualizing metrics

## Deployment

1. Deploy Prometheus and Grafana using the Helm chart:
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

2. Apply monitoring configurations:
```bash
kubectl apply -f monitoring/servicemonitor.yaml
kubectl apply -f monitoring/grafana-dashboard.yaml
```

## Access

- Grafana: Port-forward the service or access via ingress
- Prometheus: Access via Grafana or directly through port-forward

## Alerts

The following alerts are configured:
- High Error Rate
- Pod Crash Looping
- High Memory Usage
- High CPU Usage
- Database Connection Failure
- Redis Connection Failure

