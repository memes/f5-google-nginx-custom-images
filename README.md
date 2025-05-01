# Custom NGINX+ images for Google Cloud

![GitHub release](https://img.shields.io/github/v/release/memes/f5-google-nginx-custom-images?sort=semver)
![Maintenance](https://img.shields.io/maintenance/yes/2025)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

This repo provides an example for creation and testing of a pair of NGINX+ images with NGINX Agent pre-installed.

* The [static HCL] is an example of static configuration, meaning the NGINX One registration key is embedded in the disk
  image by Hashicorp Packer, and all VMs launched from the image will attempt to register to NGINX One on boot without
  additional effort. The downside to this approach is that a new image will need to be generated when the registration
  key changes.

* The [runtime HCL] is an example for runtime configuration; just like the [static HCL] example, NGINX Agent is
  installed but the configuration remains at the default. When instances are launched from this image the NGINX One
  registration key will need to be added to the configuration at runtime using a startup-script or cloud-init
  declaration. The advantage is the same custom image can be reused in different environments by changing the key in
  metadata.

> NOTE: None of these examples are ready for production use - they are only meant to be starting points to show how the
> F5 published NGINX+ PAYG images can be customised with NGINX Agent or other extensions.

## End-to-end testing

A limited end-to-end testing scenario is included in the repo and can be used as a starting point for validation.

1. Create `terraform.tfvars` in `test` directory with required parameters

   E.g. the file [terraform.tfvars.example](test/terraform.tfvars.example) looks like this

   ```hcl
   # GCP project identifier - all resources will be created in this project
   project_id = "my-gcp-project"

   # Compute Engine region - all regional and zonal resources will be created in this location
   region = "us-west1"

   # Name (and prefix) to use for test resources
   name = "my-custom-nginx-plus"

   # NGINX One key to use when registering NGINX+ instances
   #  - for the static N+ image this value will be added to /etc/nginx-agent/nginx-agent.conf in the image and used by any
   #    instance that uses the static image
   #  - for the runtime N+ image the value will be used in cloud-init files passed to the instances via metadata
   nginx_one_key = "REPLACE WITH A VALID NGINX ONE KEY"

   # An optional set of labels to add to GCP resources - the test harness will add add some additional labels to allow the
   # python tests to run the correct set of validations
   labels = {
     owner   = "username"
     purpose = "testing"
   }
   ```

1. Use `tofu` or `terraform` to create a set of testing resources for networking, firewalls, and service accounts

   <!-- spell-checker: disable -->
   ```shell
   tofu -chdir=test init
   ```

   ```text
   Initializing the backend...
   Initializing modules...
   Downloading registry.terraform.io/memes/multi-region-private-network/google 4.0.0 for vpc...
   ...

   Initializing provider plugins...
   - Finding hashicorp/tls versions matching ">= 4.0.0"...
   ...
   OpenTofu has been successfully initialized!
   ...
   ```

   ```shell
   tofu -chdir=test apply -auto-approve
   ```

   ```text
   ...
   Apply complete! Resources: 30 added, 0 changed, 0 destroyed.

   Outputs:

   harness_json = "/workspaces/f5-google-nginx-custom-images/test/harness.json"
   packer_sa = "emes-custom-nplus-packer@PROJECT_ID.iam.gserviceaccount.com"
   pkvars_file = "/workspaces/f5-google-nginx-custom-images/test/harness.pkvars.hcl"
   subnet_self_link = "https://www.googleapis.com/compute/v1/projects/PROJECT_ID/regions/us-west1/subnetworks/emes-custom-nplus-us-we1"
   tfvars_file = "/workspaces/f5-google-nginx-custom-images/test/harness.tfvars"
   zones = tolist([
     "us-west1-a",
     "us-west1-b",
     "us-west1-c",
   ])
   ```
   <!-- spell-checker: enable -->

1. Create the NGINX+ images with `packer`, using the values file created in the prior step

   <!-- spell-checker: disable -->
   ```shell
   packer init .
   ```
   <!-- spell-checker: enable -->

   > NOTE: The init step will be silent if the Google Compute Engine plugin is already fetched.

   <!-- spell-checker: disable -->
   ```shell
   packer build -force -var-file test/harness.pkvars.hcl .
   ```

   ```text
   googlecompute.nginx-runtime: output will be in this color.
   googlecompute.nginx-static: output will be in this color.
   ...
   ==> googlecompute.nginx-runtime: Connected to SSH!
   ==> googlecompute.nginx-runtime: Waiting for any running startup script to finish...
       googlecompute.nginx-runtime: Startup script not finished yet. Waiting...
   ==> googlecompute.nginx-static: Connected to SSH!
   ==> googlecompute.nginx-static: Waiting for any running startup script to finish...
       googlecompute.nginx-static: Startup script not finished yet. Waiting...
       googlecompute.nginx-runtime: Startup script not finished yet. Waiting...
   ...

   googlecompute.nginx-runtime: Startup script successfully finished.
   ==> googlecompute.nginx-runtime: Startup script, if any, has finished running.
   ==> googlecompute.nginx-runtime: Deleting instance...
       googlecompute.nginx-static: Startup script successfully finished.
   ==> googlecompute.nginx-static: Startup script, if any, has finished running.
   ==> googlecompute.nginx-static: Deleting instance...
       googlecompute.nginx-runtime: Instance has been deleted!
   ==> googlecompute.nginx-runtime: Creating image...
       googlecompute.nginx-static: Instance has been deleted!
   ==> googlecompute.nginx-static: Creating image...

   ==> googlecompute.nginx-runtime: Deleting disk...
       googlecompute.nginx-runtime: Disk has been deleted!
   Build 'googlecompute.nginx-runtime' finished after 3 minutes 28 seconds.
   ==> googlecompute.nginx-static: Deleting disk...
       googlecompute.nginx-static: Disk has been deleted!
   Build 'googlecompute.nginx-static' finished after 3 minutes 33 seconds.

   ==> Wait completed after 3 minutes 33 seconds

   ==> Builds finished. The artifacts of successful builds are:
   --> googlecompute.nginx-runtime: A disk image was created in the 'PROJECT_ID' project: emes-custom-nplus-ffdd-runtime
   --> googlecompute.nginx-static: A disk image was created in the 'PROJECT_ID' project: emes-custom-nplus-ffdd-static
   ```
   <!-- spell-checker: enable -->

   The created images can be seen in the Google Cloud console.

   ![Google Cloud console showing custom images](custom_images.png?raw=true "NGINX+ images")

1. Use `tofu` or `terraform` to launch VMs from the custom NGINX+ images, using the values file created in step 2.

   A single VM will be created that uses the [static hcl] image, and three VMs using the [runtime hcl] image with a
   combination of cloud-init configurations and a single VM without any runtime configuration settings.

   <!-- spell-checker: disable -->
   ```shell
   tofu -chdir=test/fixture init
   ```

   ```text
   Initializing the backend...

   Initializing provider plugins...
   - Finding hashicorp/google versions matching ">= 6.19.0"...
   ...
   OpenTofu has been successfully initialized!
   ...
   ```

   ```shell
   tofu -chdir=test/fixture apply -var-file=../harness.tfvars -auto-approve
   ```

   ```text
   ...
   Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
   ```
   <!-- spell-checker: enable -->

1. Validate the instances using `pytest`

   After a few seconds the new VMs should all be onboarded and executing. Since the VMs were launched with public IP
   addresses and ingress firewall rules were added in step 2, the Python scripts can verify that NGINX is responding to
   traffic on port 80 and that the NGINX and NGINX Agent services are running correctly with log entries to confirm
   NGINX One registration.

   <!-- spell-checker: disable -->
   ```shell
   uv run pytest
   ```

   ```text
   ================================================ test session starts ================================================
   platform linux -- Python 3.12.9, pytest-8.3.5, pluggy-1.5.0
   rootdir: /workspaces/f5-google-nginx-custom-images
   configfile: pyproject.toml
   plugins: testinfra-10.2.2
   collected 9 items
   test/test_custom_images.py::test_images PASSED                                                                 [ 11%]
   test/test_nginx_api_disabled_nginx_one_disabled.py::test_hosts PASSED                                          [ 22%]
   test/test_nginx_api_disabled_nginx_one_disabled.py::test_services PASSED                                       [ 33%]
   test/test_nginx_api_disabled_nginx_one_enabled.py::test_hosts PASSED                                           [ 44%]
   test/test_nginx_api_disabled_nginx_one_enabled.py::test_services PASSED                                        [ 55%]
   test/test_nginx_api_enabled_nginx_one_disabled.py::test_hosts PASSED                                           [ 66%]
   test/test_nginx_api_enabled_nginx_one_disabled.py::test_services PASSED                                        [ 77%]
   test/test_nginx_api_enabled_nginx_one_enabled.py::test_hosts PASSED                                            [ 88%]
   test/test_nginx_api_enabled_nginx_one_enabled.py::test_services PASSED                                         [100%]

   ================================================== 9 passed in 28.46s ===============================================
   ```
   <!-- spell-checker: enable -->

   As can be inferred from the testing output, three scenarios were expected to self-register to NGINX One. This is
   confirmed in the NGINX One console.

   ![NGINX One console with registered instances](nginx_one_console.png?raw=true "NGINX One console")

1. Clean-up

   Destroy the testing resources in reverse order.

   > NOTE: This does not unregister the instances from NGINX One or delete the custom NGINX+ images in Google Cloud.
   > Those will need to be removed manually.

   <!-- spell-checker: disable -->
   ```shell
   tofu -chdir=test/fixture destroy -var-file=../harness.tfvars -auto-approve
   ```

   ```text
   ...
   Destroy complete! Resources: 6 destroyed.
   ```

   ```shell
   tofu -chdir=test destroy -auto-approve
   ```

   ```text
   ...
   Destroy complete! Resources: 30 destroyed.
   ```
   <!-- spell-checker: enable -->

[static hcl]: nginx-static.pkr.hcl
[runtime hcl]: nginx-runtime.pkr.hcl
