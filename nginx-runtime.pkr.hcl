build {
  # Build a custom image that installs the NGINX agent, but does not configure it. Configuration needs to happen via
  # cloud-init or startup script.
  source "googlecompute.base" {
    name         = "nginx-runtime"
    image_name   = format("%s-runtime", var.base_name)
    image_family = coalesce(var.family_name, "unspecified") != "unspecified" ? format("%s-runtime", var.family_name) : null
    metadata = {
      "0_provision_sh" = base64encode(file(format("%s/files/install-nginx-agent.sh", path.root)))
    }
  }
}
