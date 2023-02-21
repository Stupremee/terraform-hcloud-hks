<a href="https://terraform.io">
    <img src="https://github.com/Stupremee/terraform-hcloud-hks/raw/main/assets/tf.png" alt="Terraform logo" title="Terraform" align="left" height="50" />
</a>

# Terraform HKS

An opinionated [Terraform][tf] module for deploying a Hetzner Kubernetes Cluster using [RKE2][rke2] and [Hetzner Cloud][hcloud].

### Why?

Personally, I host everything on Hetzner and always found that Hetzner is a really great choice for many use cases.
Lately I've been experimenting with Kubernetes and needed my personal development cluster, and since most cloud providers
are really expensive for personal use, I created this module. Using it I can deploy a K8s cluster really easy that is not that expensive.
Because this module was created for my personal needs, it is really opinionated about the technologies used, and not really customizable yet.
However, in the future, I want to make this module more suited for general use, and more customizable.

### Features

- [RKE2][rke2] as the kubernetes distribution
- Use of Hetzner Private Networks to reduce latency
- Integration with [Hetzner Cloud Controller Manager][hccm]
- NGINX Ingress controller using a Hetzner Load Balancer
  - Including [cert-manager][cert-manager] configured using LetsEncrypt
- [Cilium][cilium] as the Kubernetes CNI
- [Hetzner CSI][hcsi] for the storage interface
- Proper use of Hetzner Firewalls to only allow required traffic
- Installation happens using [cloud-init][cloud-init]

There are two features that I would definitely like to support in the future:

- High Availability (having multiple master nodes)
- Cluster autoscaling to allow nodes to be spawned on-demand

## Usage

1. Create a new Hetzner Cloud project and [generate an API token](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token/)
2. (optional) Generate a new SSH key, or copy your existing public SSH key. This is optional, because this module will generate it's own SSH key which you can use.
3. Copy the [`template.tf.example`](https://github.com/Stupremee/terraform-hks/blob/main/template.tf.example) file to a new, empty directory and fill in your values.
4. Deploy the cluster using the following commands. Note that this can take quite some time because it takes a while until the master node is started.

```tf
terraform init
terraform apply
```

5. Get the kubeconfig output from Terraform using `terraform output -raw kubeconfig > ~/.kube/config`.
6. Run `kubectl get nodes` and check for all running nodes. Output should look something like this:
   ![kubectl output](https://github.com/Stupremee/terraform-hcloud-hks/raw/main/assets/kubectl-get-nodes-output.png)
   You may be wondering that some agent nodes do not show up yet. This is because the module does not wait for all agents to finish their setup process, so just wait a minute and they should appear :)

[tf]: https://www.terraform.io
[rke2]: https://docs.rke2.io
[hcloud]: https://www.hetzner.com/cloud
[hccm]: https://github.com/hetznercloud/hcloud-cloud-controller-manager
[cilium]: https://cilium.io
[hcsi]: https://github.com/hetznercloud/csi-driver
[cloud-init]: https://cloud-init.io
[cert-manager]: http://cert-manager.io
