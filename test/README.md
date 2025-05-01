# Test

This folder contains Terraform declarations for supporting resources to test NGINX+ custom image generation with Packer,
and subsequent validation of VMs launched from the custom images.

See also [fixture](fixture/).

<!-- markdownlint-disable MD033 MD034 -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.19 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.4 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.4 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | registry.terraform.io/memes/multi-region-private-network/google | 4.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.nginx_ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.packer_ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_os_login_ssh_public_key.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/os_login_ssh_public_key) | resource |
| [google_project_iam_member.nginx_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.packer_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.nginx](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.packer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [local_file.harness_json](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.pkvars](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.ssh_config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.ssh_privkey](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.ssh_pubkey](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.tfvars](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_id.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_shuffle.zones](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/shuffle) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [google_client_openid_userinfo.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_openid_userinfo) | data source |
| [google_compute_zones.zones](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |
| [http_http.my_address](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name to assign to created resources. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The Google project where resources including NGINX+ images will be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The Google Compute region where resources will be created. | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | An optional set of labels to add to resources. | `map(string)` | `{}` | no |
| <a name="input_nginx_one_key"></a> [nginx\_one\_key](#input\_nginx\_one\_key) | An optional NGINX One data plane key to use when building the example NGINX+ image which is fully configured. | `string` | `null` | no |
| <a name="input_test_cidrs"></a> [test\_cidrs](#input\_test\_cidrs) | n/a | `list(any)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_harness_json"></a> [harness\_json](#output\_harness\_json) | The full path to the generated file that can be used as an input for python testing. |
| <a name="output_packer_sa"></a> [packer\_sa](#output\_packer\_sa) | The service account email to use for packer image creation. |
| <a name="output_pkvars_file"></a> [pkvars\_file](#output\_pkvars\_file) | The full path to the generated file that can be used as an input for Packer. |
| <a name="output_subnet_self_link"></a> [subnet\_self\_link](#output\_subnet\_self\_link) | The Google Compute subnetwork self-link to use when building images. |
| <a name="output_tfvars_file"></a> [tfvars\_file](#output\_tfvars\_file) | The full path to the generated file that can be used as an input for Tofu/Terraform fixtures. |
| <a name="output_zones"></a> [zones](#output\_zones) | A randomised shuffle of the Google Compute zones in specified region. |
<!-- END_TF_DOCS -->
<!-- markdownlint-enable MD033 MD034 -->
