resource "hcloud_server" "agents" {
  for_each = local.agent_nodes

  name         = "${var.prefix}-${each.key}"
  image        = "rocky-8"
  server_type  = each.value.server_type
  ssh_keys     = [for key in values(hcloud_ssh_key.keys) : key.id]
  location     = each.value.location
  user_data    = replace(local.agent_user_data, "NODE_IP", each.value.ip)
  labels       = var.labels
  firewall_ids = [hcloud_firewall.agent.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = hcloud_network.priv.id
    ip         = each.value.ip
  }

  depends_on = [
    hcloud_network_subnet.agent
  ]
}

resource "ssh_resource" "delete-node-from-cluster" {
  for_each = local.agent_nodes

  depends_on = [
    hcloud_server.master
  ]

  when = "destroy"

  host        = hcloud_server.master.ipv4_address
  user        = "root"
  agent       = false
  private_key = tls_private_key.ssh.private_key_openssh
  timeout     = "1m"

  commands = [
    "/var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml delete node ${var.prefix}-${each.key} || true"
  ]
}
