packer {
  required_version = ">= 1.7"
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1.1"
    }
  }
}

locals {
  source_image         = reverse(split("/", var.base_image))[0]
  source_image_project = reverse(split("/", var.base_image))[3]
}

# Base defines the common image characteristics; individual builders will add values to customise further.
source "googlecompute" "base" {
  project_id   = var.project_id
  source_image = local.source_image
  source_image_project_id = [
    local.source_image_project,
  ]
  zone         = var.zone
  communicator = "ssh"
  # IAP was intermittently failing during parallel builds so disable and go back to public IPs.
  use_iap               = false
  use_internal_ip       = false
  omit_external_ip      = false
  use_os_login          = true
  ssh_username          = coalesce(var.ssh_username, "root")
  ssh_private_key_file  = coalesce(var.ssh_private_key_file, "unspecified") != "unspecified" ? var.ssh_private_key_file : null
  image_description     = var.description
  image_labels          = var.labels
  service_account_email = var.service_account
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
  ]
  subnetwork          = var.subnet
  tags                = var.tags
  labels              = var.labels
  startup_script_file = format("%s/files/provisioner.sh", path.root)
  wrap_startup_script = true
}
