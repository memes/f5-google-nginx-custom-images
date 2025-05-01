variable "project_id" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "The project_id value must be a valid Google Cloud project identifier."
  }
  description = <<-EOD
  The Google project where resources including NGINX+ instances will be created.
  EOD
}

variable "zone" {
  type = string
  validation {
    condition     = can(regex("^[a-z]{2,}-[a-z]{2,}[0-9]-[a-z]$", var.zone))
    error_message = "Zone must be a valid Compute Engine zone."
  }
  description = <<-EOD
    The Google Compute zone where resources will be created.
    EOD
}

variable "name" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,53}[a-z0-9]?$", var.name))
    error_message = "The name variable must be RFC1035 compliant and between 1 and 55 characters in length."
  }
}

variable "subnet" {
  type = string
  validation {
    condition     = can(regex("^(?:https://www\\.googleapis\\.com/compute/v1/)?projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/regions/[a-z][a-z-]+[0-9]/subnetworks/[a-z]([a-z0-9-]{0,61}[a-z0-9])?$", var.subnet))
    error_message = "Subnet variable must contain a fully-qualified subnet self-link."
  }
  description = <<-EOD
  The fully-qualified subnetwork self-link to which the NGINX+ instance will be
  attached.
  EOD
}

variable "tags" {
  type        = list(string)
  default     = []
  description = <<-EOD
  An optional list of network tags to add to ephemeral NGINX+ instance.
  EOD
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = <<-EOD
  An optional set of labels to add to resources.
  EOD
}

variable "service_account" {
  type        = string
  default     = ""
  description = <<-EOD
  The service account to use when building custom NGINX+ images.
  EOD
}

variable "nginx_one_key" {
  type        = string
  default     = null
  description = <<-EOD
  An optional NGINX One data plane key to use when testing NGINX- runtime image.
  EOD
}
