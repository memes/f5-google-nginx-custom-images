build {
  # Build a custom image that installs the NGINX agent and performs customization of NGINX and agent configurations. The
  # result is an image that should be functional NGINX VM as soon as booting is complete.
  source "googlecompute.base" {
    name         = "nginx-static"
    image_name   = format("%s-static", var.base_name)
    image_family = coalesce(var.family_name, "unspecified") != "unspecified" ? format("%s-static", var.family_name) : null
    metadata = {
      "0_provision_sh" = base64encode(file(format("%s/files/install-nginx-agent.sh", path.root)))
      "1_provision_sh" = base64encode(templatefile(format("%s/templates/static-configuration.sh", path.root), {
        nginx_one_key = var.nginx_one_key
      }))
    }
  }
}
