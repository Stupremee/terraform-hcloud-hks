<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_hcloud"></a> [hcloud](#requirement\_hcloud) | 1.36.2 |
| <a name="requirement_ssh"></a> [ssh](#requirement\_ssh) | 2.6.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | 1.36.2 |
| <a name="provider_ssh"></a> [ssh](#provider\_ssh) | 2.6.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [hcloud_firewall.agent](https://registry.terraform.io/providers/hetznercloud/hcloud/1.36.2/docs/resources/firewall) | resource |
| [hcloud_firewall.master](https://registry.terraform.io/providers/hetznercloud/hcloud/1.36.2/docs/resources/firewall) | resource |
| [hcloud_network.priv](https://registry.terraform.io/providers/hetznercloud/hcloud/1.36.2/docs/resources/network) | resource |
| [hcloud_network_subnet.agent](https://registry.terraform.io/providers/hetznercloud/hcloud/1.36.2/docs/resources/network_subnet) | resource |
| [hcloud_network_subnet.master](https://registry.terraform.io/providers/hetznercloud/hcloud/1.36.2/docs/resources/network_subnet) | resource |
| [hcloud_server.agents](https://registry.terraform.io/providers/hetznercloud/hcloud/1.36.2/docs/resources/server) | resource |
| [hcloud_server.master](https://registry.terraform.io/providers/hetznercloud/hcloud/1.36.2/docs/resources/server) | resource |
| [hcloud_ssh_key.keys](https://registry.terraform.io/providers/hetznercloud/hcloud/1.36.2/docs/resources/ssh_key) | resource |
| [ssh_resource.delete-node-from-cluster](https://registry.terraform.io/providers/loafoe/ssh/2.6.0/docs/resources/resource) | resource |
| [ssh_resource.k8s-addon-manifests](https://registry.terraform.io/providers/loafoe/ssh/2.6.0/docs/resources/resource) | resource |
| [ssh_sensitive_resource.kubeconfig](https://registry.terraform.io/providers/loafoe/ssh/2.6.0/docs/resources/sensitive_resource) | resource |
| [ssh_sensitive_resource.master-ssh-keys](https://registry.terraform.io/providers/loafoe/ssh/2.6.0/docs/resources/sensitive_resource) | resource |
| [ssh_sensitive_resource.node-token](https://registry.terraform.io/providers/loafoe/ssh/2.6.0/docs/resources/sensitive_resource) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/4.0.4/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_nodepools"></a> [agent\_nodepools](#input\_agent\_nodepools) | List of nodepools used as agents in the cluster | <pre>list(object({<br>    name        = string<br>    server_type = string<br>    location    = string<br>    count       = number<br>  }))</pre> | n/a | yes |
| <a name="input_cert-manager"></a> [cert-manager](#input\_cert-manager) | Option for customizing the cert-manager instance that will be deployed | <pre>object({<br>    email = string<br>  })</pre> | n/a | yes |
| <a name="input_hcloud_token"></a> [hcloud\_token](#input\_hcloud\_token) | The token for accessing the Hetzner API | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Hetzner Labels to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_loadbalancer"></a> [loadbalancer](#input\_loadbalancer) | Configure the Load Balancer that will be created | <pre>object({<br>    type     = string<br>    location = string<br>  })</pre> | n/a | yes |
| <a name="input_master_node"></a> [master\_node](#input\_master\_node) | List of nodepools which will serve as a master | <pre>object({<br>    name        = string<br>    server_type = string<br>    location    = string<br>  })</pre> | n/a | yes |
| <a name="input_network_zone"></a> [network\_zone](#input\_network\_zone) | Zone for all the networks | `string` | n/a | yes |
| <a name="input_perform_system_update"></a> [perform\_system\_update](#input\_perform\_system\_update) | If set to true, a system update will be performed on each node before starting RKE2 | `bool` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Common prefix for all services | `string` | n/a | yes |
| <a name="input_ssh_port"></a> [ssh\_port](#input\_ssh\_port) | The main SSH port to connect to the nodes | `number` | `22` | no |
| <a name="input_ssh_public_keys"></a> [ssh\_public\_keys](#input\_ssh\_public\_keys) | The ssh public keys which can be used to connect to the nodes | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Kubeconfig in YAML format |
| <a name="output_kubeconfig_data"></a> [kubeconfig\_data](#output\_kubeconfig\_data) | Kubeconfig as structured data to pass values to other provider |
<!-- END_TF_DOCS -->
