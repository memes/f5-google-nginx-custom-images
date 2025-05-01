# Creates test resources that can be consumed by NGINX+ VMs launched from custom images

data "http" "my_address" {
  url = "https://checkip.amazonaws.com"
  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Failed to get local IP address"
    }
  }
}

resource "google_service_account" "nginx" {
  project      = var.project_id
  account_id   = format("%s-nginx", var.name)
  display_name = "Test account for NGINX+"
  description  = "Test account for custom NGINX+ image validation"
}

resource "google_project_iam_member" "nginx_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/compute.osLogin",
  ])
  project = var.project_id
  member  = google_service_account.packer.member
  role    = each.key
}

resource "google_compute_firewall" "nginx_ingress" {
  project       = var.project_id
  name          = format("%s-allow-nginx-ingress", var.name)
  network       = module.vpc.self_link
  description   = "Allow tester access to NGINX+ instances"
  direction     = "INGRESS"
  priority      = 900
  source_ranges = coalescelist(var.test_cidrs, [format("%s/32", trimspace(data.http.my_address.response_body))])
  target_service_accounts = [
    google_service_account.nginx.email,
  ]
  allow {
    protocol = "tcp"
    ports = [
      22,
      80,
    ]
  }
  depends_on = [
    module.vpc,
    google_service_account.nginx,
  ]
}

resource "local_file" "ssh_config" {
  filename = format("%s/%s-ssh-config", path.module, var.name)
  content  = <<-EOC
  Host *
  	User ${replace(data.google_client_openid_userinfo.default.email, "/[^a-z0-9-]/", "_")}
  	CheckHostIP no
  	IdentitiesOnly yes
  	IdentityFile ${abspath(local_file.ssh_privkey.filename)}
  	UserKnownHostsFile /dev/null
  	StrictHostKeyChecking no
  EOC
  depends_on = [
    tls_private_key.ssh,
  ]
}

resource "local_file" "tfvars" {
  filename        = format("%s/harness.tfvars", path.module)
  file_permission = "0600"
  content         = <<-EOC
  project_id      = "${var.project_id}"
  zone            = "${random_shuffle.zones.result[0]}"
  service_account = "${google_service_account.nginx.email}"
  subnet          = "${module.vpc.subnets_by_region[var.region].self_link}"
  name            = "${var.name}"
  nginx_one_key   = "${coalesce(var.nginx_one_key, "unspecified") == "unspecified" ? null : var.nginx_one_key}"
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
    google_service_account.nginx,
    module.vpc,
    google_compute_firewall.nginx_ingress,
  ]
}

# Create an attributes file for values that are shared between scenarios
resource "local_file" "harness_json" {
  filename = format("%s/harness.json", path.module)
  content = jsonencode({
    name        = var.name
    project_id  = var.project_id
    ssh_config  = abspath(local_file.ssh_config.filename)
    ssh_privkey = abspath(local_file.ssh_privkey.filename)
    labels      = local.common_labels
    zone        = random_shuffle.zones.result[0],
  })

  depends_on = [
    google_service_account.nginx,
    module.vpc,
    local_file.ssh_privkey,
    local_file.ssh_pubkey,
    local_file.ssh_config,
    google_compute_firewall.nginx_ingress,
  ]
}
