terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.19"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.4"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
  }
}

data "google_compute_zones" "zones" {
  project = var.project_id
  region  = var.region
  status  = "UP"
}

data "google_client_openid_userinfo" "default" {}

resource "random_shuffle" "zones" {
  input = data.google_compute_zones.zones.names
  keepers = {
    project_id = var.project_id
    region     = var.region
  }
}

resource "random_id" "suffix" {
  byte_length = 2
  keepers = {
    project_id = var.project_id
    region     = var.region
  }
}

locals {
  common_labels = var.labels == null ? { use-case = "custom-nginx-test" } : merge({ use-case = "custom-nginx-test" }, var.labels)
}

module "vpc" {
  source     = "registry.terraform.io/memes/multi-region-private-network/google"
  version    = "4.0.0"
  project_id = var.project_id
  name       = var.name
  regions = [
    var.region,
  ]
  nat = {
    tags = [
      format("%s-allow-nat", var.name),
    ]
    logging_filter = "ERRORS_ONLY"
  }
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_privkey" {
  filename        = format("%s/%s-ssh", path.module, var.name)
  file_permission = "0600"
  content         = tls_private_key.ssh.private_key_pem
}

resource "local_file" "ssh_pubkey" {
  filename        = format("%s/%s-ssh.pub", path.module, var.name)
  file_permission = "0600"
  content         = tls_private_key.ssh.public_key_openssh
}

resource "google_os_login_ssh_public_key" "default" {
  user = data.google_client_openid_userinfo.default.email
  key  = trimspace(tls_private_key.ssh.public_key_openssh)
}
