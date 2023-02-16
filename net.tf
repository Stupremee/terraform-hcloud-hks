resource "hcloud_network" "priv" {
  name     = "${var.prefix}-private-net"
  ip_range = local.network_cidr
  labels   = var.labels
}

resource "hcloud_network_subnet" "master" {
  network_id   = hcloud_network.priv.id
  type         = "server"
  network_zone = var.network_zone
  ip_range     = "10.1.0.0/16"
}

resource "hcloud_network_subnet" "agent" {
  network_id   = hcloud_network.priv.id
  type         = "server"
  network_zone = var.network_zone
  ip_range     = "10.2.0.0/16"
}

resource "hcloud_firewall" "master" {
  name = "${var.prefix}-master-firewall"

  labels = var.labels

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "6443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
    description = "Allow Kubernetes API server port for remotely controlling the K8s cluster"
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "9345"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
    description = "Allow Kubernetes API server port for remotely controlling the K8s cluster"
  }
}

resource "hcloud_firewall" "agent" {
  name = "${var.prefix}-agent-firewall"

  labels = var.labels

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "10250"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
    description = "Allow access to the Kubelet API"
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = var.ssh_port
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
    description = "Allow SSH access"
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "any"
    source_ips = [
      hcloud_network.priv.ip_range,
      local.hetzner_metadata_service_ipv4,
      local.hetzner_cloud_api_ipv4
    ]
    description = "Allow all TCP traffic from whitelisted IPs"
  }

  rule {
    direction = "in"
    protocol  = "udp"
    port      = "any"
    source_ips = [
      hcloud_network.priv.ip_range,
      local.hetzner_metadata_service_ipv4,
      local.hetzner_cloud_api_ipv4
    ]
    description = "Allow all UDP traffic from whitelisted IPs"
  }

  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      hcloud_network.priv.ip_range,
      local.hetzner_metadata_service_ipv4,
      local.hetzner_cloud_api_ipv4
    ]
    description = "Allow all ICMP from whitelisted IPs"
  }
}
