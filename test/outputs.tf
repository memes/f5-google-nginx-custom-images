output "zones" {
  value       = random_shuffle.zones.result
  description = <<-EOD
  A randomised shuffle of the Google Compute zones in specified region.
  EOD
}

output "packer_sa" {
  value       = google_service_account.packer.email
  description = <<-EOD
  The service account email to use for packer image creation.
  EOD
}

output "subnet_self_link" {
  value       = module.vpc.subnets_by_region[var.region].self_link
  description = <<-EOD
  The Google Compute subnetwork self-link to use when building images.
  EOD
}

output "pkvars_file" {
  value       = abspath(local_file.pkvars.filename)
  description = <<-EOD
  The full path to the generated file that can be used as an input for Packer.
  EOD
}

output "tfvars_file" {
  value       = abspath(local_file.tfvars.filename)
  description = <<-EOD
  The full path to the generated file that can be used as an input for Tofu/Terraform fixtures.
  EOD
}

output "harness_json" {
  value       = abspath(local_file.harness_json.filename)
  description = <<-EOD
  The full path to the generated file that can be used as an input for python testing.
  EOD
}
