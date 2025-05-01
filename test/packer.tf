# Creates resources used for Packer image builder instances

resource "google_service_account" "packer" {
  project      = var.project_id
  account_id   = format("%s-packer", var.name)
  display_name = "Packer builder for custom NGINX+"
  description  = "Packer account for NGINX+ image building"
}

resource "google_project_iam_member" "packer_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/compute.osLogin",
    "roles/compute.instanceAdmin.v1",
    "roles/iam.serviceAccountUser",
  ])
  project = var.project_id
  member  = google_service_account.packer.member
  role    = each.key
}

resource "google_compute_firewall" "packer_ingress" {
  project       = var.project_id
  name          = format("%s-allow-packer-ingress", var.name)
  network       = module.vpc.self_link
  description   = "Allow tester access to Packer builder instances"
  direction     = "INGRESS"
  priority      = 900
  source_ranges = coalescelist(var.test_cidrs, [format("%s/32", trimspace(data.http.my_address.response_body))])
  target_service_accounts = [
    google_service_account.packer.email,
  ]
  allow {
    protocol = "tcp"
    ports = [
      22,
    ]
  }
  depends_on = [
    module.vpc,
    google_service_account.packer,
  ]
}

resource "local_file" "pkvars" {
  filename        = format("%s/harness.pkvars.hcl", path.module)
  file_permission = "0600"
  content         = <<-EOC
  project_id           = "${var.project_id}"
  base_name            = "${format("%s-%s", var.name, random_id.suffix.hex)}"
  family_name          = "${var.name}"
  nginx_one_key        = "${coalesce(var.nginx_one_key, "unspecified") == "unspecified" ? null : var.nginx_one_key}"
  zone                 = "${random_shuffle.zones.result[0]}"
  service_account      = "${google_service_account.packer.email}"
  ssh_username         = "${replace(data.google_client_openid_userinfo.default.email, "/[^a-z0-9-]/", "_")}"
  ssh_private_key_file = "${abspath(local_file.ssh_privkey.filename)}"
  subnet               = "${module.vpc.subnets_by_region[var.region].self_link}"
  tags = [
    "${format("%s-allow-nat", var.name)}",
  ]
  labels = {
%{for k, v in local.common_labels~}
    ${k} = "${v}"
%{endfor~}
}
  EOC

  depends_on = [
    google_service_account.packer,
    module.vpc,
    google_compute_firewall.packer_ingress,
  ]
}
