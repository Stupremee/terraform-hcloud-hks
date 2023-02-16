resource "hcloud_server" "master" {
  name         = "${var.prefix}-${var.master_node.name}"
  image        = "rocky-8"
  server_type  = var.master_node.server_type
  ssh_keys     = [for key in values(hcloud_ssh_key.keys) : key.id]
  location     = var.master_node.location
  user_data    = local.master_user_data
  labels       = var.labels
  firewall_ids = [hcloud_firewall.master.id, hcloud_firewall.agent.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = hcloud_network.priv.id
    ip         = local.master_ip
  }

  depends_on = [
    hcloud_network_subnet.master
  ]
}

resource "ssh_resource" "k8s-addon-manifests" {
  when = "create"

  host        = hcloud_server.master.ipv4_address
  user        = "root"
  agent       = false
  private_key = tls_private_key.ssh.private_key_openssh
  timeout     = "1m"

  triggers = local.manifests

  dynamic "file" {
    for_each = local.manifests
    content {
      content     = sensitive(file.value)
      destination = "/var/lib/rancher/rke2/server/manifests/${file.key}"
    }
  }
}

resource "ssh_sensitive_resource" "kubeconfig" {
  when = "create"

  host        = hcloud_server.master.ipv4_address
  user        = "root"
  agent       = false
  private_key = tls_private_key.ssh.private_key_openssh
  timeout     = "10m"

  commands = [
    "cloud-init status --wait > /dev/null",
    "cat /etc/rancher/rke2/rke2.yaml"
  ]
}

resource "ssh_sensitive_resource" "node-token" {
  when = "create"

  host        = hcloud_server.master.ipv4_address
  user        = "root"
  agent       = false
  private_key = tls_private_key.ssh.private_key_openssh
  timeout     = "10m"

  commands = [
    "cat /var/lib/rancher/rke2/server/node-token"
  ]

  depends_on = [
    ssh_sensitive_resource.kubeconfig
  ]
}

resource "ssh_sensitive_resource" "master-ssh-keys" {
  when = "create"

  host        = hcloud_server.master.ipv4_address
  user        = "root"
  agent       = false
  private_key = tls_private_key.ssh.private_key_openssh
  timeout     = "10m"

  commands = [
    "cat /etc/ssh/ssh_host_*_key.pub"
  ]
}
