variable "project_id" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "The project_id value must be a valid Google Cloud project identifier."
  }
  description = <<-EOD
  The Google project where resources including NGINX+ images will be created.
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

variable "base_image" {
  type = string
  validation {
    condition     = can(regex("^(?:https://www\\.googleapis\\.com/compute/v1/)?projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/global/images/.*$", var.base_image))
    error_message = "The base_image must refer to a fully-qualified Compute Engine image name."
  }
  default     = "projects/nginx-public/global/images/nginx-plus-ubuntu2404-premium-v20250207"
  description = <<-EOD
  The base NGINX+ image to use when creating the custom image. Default is latest
  F5 published premium Ubuntu image from marketplace at the time of module creation.
  EOD
}

variable "base_name" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,53}[a-z0-9]?$", var.base_name))
    error_message = "The base_name variable must be RFC1035 compliant and between 1 and 55 characters in length."
  }
  description = <<-EOD
  The base name to use as the prefix for the generated image(s).
  E.g. with base_name = "my-nginx-v2", images will be generated with image names
  "my-nginx-v2-runtime" and "my-nginx-v2-final".
  EOD
}

variable "description" {
  type = string
  validation {
    condition     = var.description == null ? true : length(var.description) <= 256
    error_message = "Description must be less than 256 characters."
  }
  default     = "Packer for NGINX+ image building"
  description = <<-EOD
  An optional description for the image.
  EOD
}

variable "family_name" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,53}[a-z0-9]?$", var.family_name))
    error_message = "The family_name variable must be RFC1035 compliant and between 1 and 55 characters in length."
  }
  default     = "nginx"
  description = <<-EOD
  An optional base family name to use as a prefix for generated images.
  E.g. with family_name = "my-nginx", images will be generated with family names
  "my-nginx-runtime", "my-nginx-static".
  EOD
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
  An optional list of network tags to add to ephemeral NGINX+ image.
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

variable "ssh_username" {
  type    = string
  default = "root"
}

variable "ssh_private_key_file" {
  type = string
  validation {
    condition     = coalesce(var.ssh_private_key_file, "unspecified") == "unspecified" ? true : can(fileexists(var.ssh_private_key_file))
    error_message = "If ssh_private_key_file is not null or empty, it must be a path to an existing file."
  }
  default = null
}

variable "nginx_one_key" {
  type        = string
  default     = "c0dec0dec0dec0de"
  description = <<-EOD
  An optional NGINX One data plane key to use when building the example NGINX+ image which is fully configured. Default
  value is a dummy key that will fail to join NGINX One.
  EOD
}
