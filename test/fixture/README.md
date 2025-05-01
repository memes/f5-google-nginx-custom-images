# Test fixture

This folder contains Terraform declarations to launch VMs from custom NGINX+ images created by the Packer files in root.

<!-- markdownlint-disable MD033 MD034 -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.19 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_instance.rt_api_only_config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance.rt_both_config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance.rt_no_api_config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance.rt_without_config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance.static](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [random_id.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The Google project where resources including NGINX+ instances will be created. | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | The fully-qualified subnetwork self-link to which the NGINX+ instance will be<br/>attached. | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | The Google Compute zone where resources will be created. | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | An optional set of labels to add to resources. | `map(string)` | `{}` | no |
| <a name="input_nginx_one_key"></a> [nginx\_one\_key](#input\_nginx\_one\_key) | An optional NGINX One data plane key to use when testing NGINX- runtime image. | `string` | `null` | no |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | The service account to use when building custom NGINX+ images. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | An optional list of network tags to add to ephemeral NGINX+ instance. | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
<!-- markdownlint-enable MD033 MD034 -->
