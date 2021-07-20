locals {
  yaml_location     = "${path.module}/${var.yaml_location}"
  metrics_file_name = var.metrics_file_name
  metrics_yaml = templatefile("${path.module}/templates/${var.metrics_template_name}", {
    namespace = var.namespace
  })
}

resource "local_file" "metrics_yaml" {
  content         = local.metrics_yaml
  filename        = "${local.yaml_location}/${local.metrics_file_name}"
  file_permission = "0644"
}

resource "null_resource" "execute_kuma_metrics_install" {
  triggers = {
    metrics_file_name = local.metrics_file_name
    yaml_location     = local.yaml_location
  }

  depends_on = [local_file.metrics_yaml]

  provisioner "local-exec" {
    command     = "kubectl apply -f ${self.triggers.metrics_file_name}"
    working_dir = self.triggers.yaml_location
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "kubectl delete -f ${self.triggers.metrics_file_name}"
    working_dir = self.triggers.yaml_location
  }

  provisioner "local-exec" {
    command = "while [[ $(kubectl get pods -l app=prometheus,component=server -n ${var.namespace} -o 'jsonpath={..status.conditions[?(@.type==\"Ready\")].status}') != 'True' ]]; do echo 'waiting for prometheus server to enter ready state'; sleep 1; done"
  }

  provisioner "local-exec" {
    command = "while [[ $(kubectl get pods -l app=prometheus,component=kube-state-metrics -n ${var.namespace} -o 'jsonpath={..status.conditions[?(@.type==\"Ready\")].status}') != 'True' ]]; do echo 'waiting for kube state metrics to enter ready state'; sleep 1; done"
  }
}

data "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = var.namespace
  }
  depends_on = [null_resource.execute_kuma_metrics_install]
}

data "kubernetes_service" "prometheus-alertmanager" {
  metadata {
    name      = "prometheus-alertmanager"
    namespace = var.namespace
  }
  depends_on = [null_resource.execute_kuma_metrics_install]
}

data "kubernetes_service" "prometheus-kube-state-metrics" {
  metadata {
    name      = "prometheus-kube-state-metrics"
    namespace = var.namespace
  }
  depends_on = [null_resource.execute_kuma_metrics_install]
}

data "kubernetes_service" "prometheus-node-exporter" {
  metadata {
    name      = "prometheus-node-exporter"
    namespace = var.namespace
  }
  depends_on = [null_resource.execute_kuma_metrics_install]
}

data "kubernetes_service" "prometheus-pushgateway" {
  metadata {
    name      = "prometheus-pushgateway"
    namespace = var.namespace
  }
  depends_on = [null_resource.execute_kuma_metrics_install]
}

data "kubernetes_service" "prometheus-server" {
  metadata {
    name      = "prometheus-server"
    namespace = var.namespace
  }
  depends_on = [null_resource.execute_kuma_metrics_install]
}

# some local variables to clean up output
locals {

  ######### grafana ##############################
  grafana_ip = try(
    data.kubernetes_service.grafana.status.0.load_balancer.0.ingress.0.ip,
    data.kubernetes_service.grafana.spec.0.cluster_ip
  )

  grafana_port              = data.kubernetes_service.grafana.spec.0.port.0.port
  grafana_interanl_dns      = "${data.kubernetes_service.grafana.metadata.0.name}.${var.namespace}.svc.cluster.local"
  grafana_internal_endpoint = "${local.grafana_interanl_dns}:${local.grafana_port}"

  ######### prometheus-alertmanager ##############
  alertmanager_ip = try(
    data.kubernetes_service.prometheus-alertmanager.status.0.load_balancer.0.ingress.0.ip,
    data.kubernetes_service.prometheus-alertmanager.spec.0.cluster_ip
  )

  alertmanager_port = data.kubernetes_service.prometheus-alertmanager.spec.0.port.0.port

  alertmanager_interanl_dns      = "${data.kubernetes_service.prometheus-alertmanager.metadata.0.name}.${var.namespace}.svc.cluster.local"
  alertmanager_internal_endpoint = "${local.alertmanager_interanl_dns}:${local.alertmanager_port}"

  ######### prometheus-kube-state-metrics ##############
  kube_state_metrics_ip = try(
    data.kubernetes_service.prometheus-kube-state-metrics.status.0.load_balancer.0.ingress.0.ip,
    data.kubernetes_service.prometheus-kube-state-metrics.spec.0.cluster_ip
  )
  kube_state_metrics_port = data.kubernetes_service.prometheus-kube-state-metrics.spec.0.port.0.port

  kube_state_metrics_interanl_dns      = "${data.kubernetes_service.prometheus-kube-state-metrics.metadata.0.name}.${var.namespace}.svc.cluster.local"
  kube_state_metrics_internal_endpoint = "${local.kube_state_metrics_interanl_dns}:${local.kube_state_metrics_port}"

  ######### prometheus-node-exporter ##############
  node_exporter_ip = try(
    data.kubernetes_service.prometheus-node-exporter.status.0.load_balancer.0.ingress.0.ip,
    data.kubernetes_service.prometheus-node-exporter.spec.0.cluster_ip
  )
  node_exporter_port = data.kubernetes_service.prometheus-node-exporter.spec.0.port.0.port

  node_exporter_interanl_dns      = "${data.kubernetes_service.prometheus-node-exporter.metadata.0.name}.${var.namespace}.svc.cluster.local"
  node_exporter_internal_endpoint = "${local.node_exporter_interanl_dns}:${local.node_exporter_port}"

  ######### prometheus-pushgateway ##############
  pushgateway_ip = try(
    data.kubernetes_service.prometheus-pushgateway.status.0.load_balancer.0.ingress.0.ip,
    data.kubernetes_service.prometheus-pushgateway.spec.0.cluster_ip
  )
  pushgateway_port = data.kubernetes_service.prometheus-pushgateway.spec.0.port.0.port

  pushgateway_interanl_dns      = "${data.kubernetes_service.prometheus-pushgateway.metadata.0.name}.${var.namespace}.svc.cluster.local"
  pushgateway_internal_endpoint = "${local.pushgateway_interanl_dns}:${local.pushgateway_port}"

  ######### prometheus-server ##############
  server_ip = try(
    data.kubernetes_service.prometheus-server.status.0.load_balancer.0.ingress.0.ip,
    data.kubernetes_service.prometheus-server.spec.0.cluster_ip
  )
  server_port = data.kubernetes_service.prometheus-server.spec.0.port.0.port

  server_interanl_dns      = "${data.kubernetes_service.prometheus-server.metadata.0.name}.${var.namespace}.svc.cluster.local"
  server_internal_endpoint = "${local.server_interanl_dns}:${local.server_port}"
}
