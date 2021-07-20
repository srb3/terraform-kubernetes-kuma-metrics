locals {
}

output "grafana_ip" {
  value = local.grafana_ip
}

output "grafana_port" {
  value = local.grafana_port
}

output "prometheus_alertmanager_ip" {
  value = local.alertmanager_ip
}

output "prometheus_alertmanager_port" {
  value = local.alertmanager_port
}

output "kube_state_metrics_ip" {
  value = local.kube_state_metrics_ip
}

output "kube_state_metrics_port" {
  value = local.kube_state_metrics_port
}

output "node_exporter_ip" {
  value = local.node_exporter_ip
}

output "node_exporter_port" {
  value = local.node_exporter_port
}

output "pushgateway_ip" {
  value = local.pushgateway_ip
}

output "pushgateway_port" {
  value = local.pushgateway_port
}
