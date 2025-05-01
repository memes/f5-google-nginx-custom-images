terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.19"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
  }
}

resource "random_id" "suffix" {
  byte_length = 2
  keepers = {
    project_id = var.project_id
    zone       = var.zone
  }
}

locals {
  common_labels             = var.labels == null ? {} : var.labels
  expect_nginx_api_enabled  = { expect-nginx-api = "enabled" }
  expect_nginx_api_disabled = { expect-nginx-api = "disabled" }
  expect_nginx_one_enabled  = { expect-nginx-one = "enabled" }
  expect_nginx_one_disabled = { expect-nginx-one = "disabled" }
}

# Launch an instance from the runtime config custom image; since a specific config is not provided at runtime we expect
# NGINX to be "okay" due to default upstream config, but nginx-agent will be failing because it is not configured.
resource "google_compute_instance" "rt_without_config" {
  project      = var.project_id
  name         = format("%s-rt-nocfg-%s", var.name, random_id.suffix.hex)
  description  = "Test NGINX+ instance from custom image; runtime config expected but not provided."
  machine_type = "e2-medium"
  zone         = var.zone
  labels       = merge(local.common_labels, local.expect_nginx_api_disabled, local.expect_nginx_one_disabled)
  metadata = {
    enable-oslogin = "TRUE"
  }
  service_account {
    email = var.service_account
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  boot_disk {
    auto_delete = true
    initialize_params {
      type   = "pd-standard"
      image  = format("projects/%s/global/images/family/%s-runtime", var.project_id, var.name)
      labels = local.common_labels
    }
  }
  tags           = var.tags
  can_ip_forward = false
  network_interface {
    subnetwork = var.subnet
    access_config {}
  }
}

# Launch an instance from the runtime config custom image and a cloud-config added to user-data metadata; this is
# expected to be serving traffic and registered with NGINX One.
resource "google_compute_instance" "rt_both_config" {
  project      = var.project_id
  name         = format("%s-rt-both-cfg-%s", var.name, random_id.suffix.hex)
  description  = "Test NGINX+ instance from custom image; runtime config expected but not provided."
  machine_type = "e2-medium"
  zone         = var.zone
  labels       = merge(local.common_labels, local.expect_nginx_api_enabled, local.expect_nginx_one_enabled)
  metadata = {
    enable-oslogin = "TRUE"
    user-data = templatefile(format("%s/templates/cloud-config-both.yaml", path.module), {
      nginx_one_key = var.nginx_one_key
    })
  }
  service_account {
    email = var.service_account
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  boot_disk {
    auto_delete = true
    initialize_params {
      type   = "pd-standard"
      image  = format("projects/%s/global/images/family/%s-runtime", var.project_id, var.name)
      labels = local.common_labels
    }
  }
  tags           = var.tags
  can_ip_forward = false
  network_interface {
    subnetwork = var.subnet
    access_config {}
  }
}

# Launch an instance from the runtime config custom image and a cloud-config added to user-data metadata; this is
# expected to be serving traffic and registered with NGINX One.
resource "google_compute_instance" "rt_api_only_config" {
  project      = var.project_id
  name         = format("%s-rt-api-cfg-%s", var.name, random_id.suffix.hex)
  description  = "Test NGINX+ instance from custom image; runtime config expected but not provided."
  machine_type = "e2-medium"
  zone         = var.zone
  labels       = merge(local.common_labels, local.expect_nginx_api_enabled, local.expect_nginx_one_disabled)
  metadata = {
    enable-oslogin = "TRUE"
    user-data      = templatefile(format("%s/templates/cloud-config-api-only.yaml", path.module), {})
  }
  service_account {
    email = var.service_account
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  boot_disk {
    auto_delete = true
    initialize_params {
      type   = "pd-standard"
      image  = format("projects/%s/global/images/family/%s-runtime", var.project_id, var.name)
      labels = local.common_labels
    }
  }
  tags           = var.tags
  can_ip_forward = false
  network_interface {
    subnetwork = var.subnet
    access_config {}
  }
}

# Launch an instance from the runtime config custom image and a cloud-config added to user-data metadata; this is
# expected to be serving traffic and registered with NGINX One.
resource "google_compute_instance" "rt_no_api_config" {
  project      = var.project_id
  name         = format("%s-rt-no-api-cfg-%s", var.name, random_id.suffix.hex)
  description  = "Test NGINX+ instance from custom image; runtime config expected but not provided."
  machine_type = "e2-medium"
  zone         = var.zone
  labels       = merge(local.common_labels, local.expect_nginx_api_disabled, local.expect_nginx_one_enabled)
  metadata = {
    enable-oslogin = "TRUE"
    user-data = templatefile(format("%s/templates/cloud-config-no-api.yaml", path.module), {
      nginx_one_key = var.nginx_one_key
    })
  }
  service_account {
    email = var.service_account
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  boot_disk {
    auto_delete = true
    initialize_params {
      type   = "pd-standard"
      image  = format("projects/%s/global/images/family/%s-runtime", var.project_id, var.name)
      labels = local.common_labels
    }
  }
  tags           = var.tags
  can_ip_forward = false
  network_interface {
    subnetwork = var.subnet
    access_config {}
  }
}

# Launch an instance from the static config custom image; since a (hopefully) valid configuration was baked in expect
# that NGINX+ has API enabled and is registered with NGINX One.
resource "google_compute_instance" "static" {
  project      = var.project_id
  name         = format("%s-static-%s", var.name, random_id.suffix.hex)
  description  = "Test NGINX+ instance from custom image; static configuration baked into image."
  machine_type = "e2-medium"
  zone         = var.zone
  labels       = merge(local.common_labels, local.expect_nginx_api_enabled, local.expect_nginx_one_enabled)
  metadata = {
    enable-oslogin = "TRUE"
  }
  service_account {
    email = var.service_account
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  boot_disk {
    auto_delete = true
    initialize_params {
      type   = "pd-standard"
      image  = format("projects/%s/global/images/family/%s-static", var.project_id, var.name)
      labels = local.common_labels
    }
  }
  tags           = var.tags
  can_ip_forward = false
  network_interface {
    subnetwork = var.subnet
    access_config {}
  }
}
