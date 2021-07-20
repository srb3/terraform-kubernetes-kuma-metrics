variable "yaml_location" {
  description = "The temporary folder for holding the kuma metrics yaml files. Relative to the module directory"
  type        = string
  default     = "temp_files/yamls"
}

variable "metrics_file_name" {
  description = "The name to give the metrics yaml file"
  type        = string
  default     = "metrics.yaml"
}

variable "metrics_template_name" {
  description = "The name of the metrics template"
  type        = string
  default     = "metrics.yaml"
}

variable "namespace" {
  description = "The namespace to use for the kuma metrics deployments"
  type        = string
  default     = "kuma-metrics"
}
