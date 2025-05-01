variable "name" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,21}[a-z0-9]$", var.name))
    error_message = "The name variable must be RFC1035 compliant and between 6 and 23 characters in length."
  }
  description = <<-EOD
  The name to assign to created resources.
  EOD
}

variable "project_id" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "The project_id value must be a valid Google Cloud project identifier"
  }
  description = <<-EOD
  The Google project where resources including NGINX+ images will be created.
  EOD
}

variable "region" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("^[a-z]{2,}-[a-z]{2,}[0-9]$", var.region))
    error_message = "Region must be a valid Compute Engine region."
  }
  description = <<-EOD
    The Google Compute region where resources will be created.
    EOD
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = <<-EOD
  An optional set of labels to add to resources.
  EOD
}

variable "test_cidrs" {
  type    = list(any)
  default = []
}

variable "nginx_one_key" {
  type        = string
  default     = null
  description = <<-EOD
  An optional NGINX One data plane key to use when building the example NGINX+ image which is fully configured.
  EOD
}
