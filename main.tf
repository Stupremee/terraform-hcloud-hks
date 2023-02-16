provider "hcloud" {
  token = var.hcloud_token
}

resource "tls_private_key" "ssh" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "hcloud_ssh_key" "keys" {
  for_each   = merge(var.ssh_public_keys, { tf = tls_private_key.ssh.public_key_openssh })
  name       = "${var.prefix}-${each.key}"
  public_key = sensitive(each.value)
  labels     = var.labels
}
