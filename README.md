# terraform-kubernetes-kuma-metrics

A terraform module for deploying the kuma metrics example
into Kubernetes

## Usage

### Example deployment

```HCL

module "kuma_metrics" {
  source = "terraform/kuma-metrics/kubernetes"
  namespace = "kuma-metrics"
}
```

## Testing

Tests are run via the makefile
