locals {
  network_cidr                  = "10.0.0.0/8"
  master_ip                     = "10.1.0.1"
  agent_ip_prefix               = "10.2."
  hetzner_metadata_service_ipv4 = "169.254.169.254/32"
  hetzner_cloud_api_ipv4        = "213.239.246.1/32"

  manifests = {
    "hcloud-token.yaml" : templatefile(
      "${path.module}/manifests/hcloud-token.yaml.tpl",
      {
        token   = base64encode(var.hcloud_token),
        network = base64encode(hcloud_network.priv.id)
      }
    ),
    "hcloud-ccm.yaml" : file("${path.module}/manifests/hcloud-ccm.yaml"),
    "hcloud-csi.yaml" : file("${path.module}/manifests/hcloud-csi.yaml"),
    "cert-manager.yaml" : templatefile(
      "${path.module}/manifests/cert-manager.yaml.tpl",
      {
        email = var.cert-manager.email
      }
    ),
    "rke2-ingress-nginx-config.yaml" : templatefile(
      "${path.module}/manifests/ingress-nginx-config.yaml.tpl",
      {
        name     = "${var.prefix}-lb",
        location = var.loadbalancer.location,
        type     = var.loadbalancer.type
      }
    ),
  }

  configure_ssh = <<EOT
  - echo "UsePAM yes" > /etc/ssh/sshd_config
  - echo "Banner none" >> /etc/ssh/sshd_config
  - echo "AddressFamily any" >> /etc/ssh/sshd_config
  - echo "Port 22" >> /etc/ssh/sshd_config
  - echo "X11Forwarding no" >> /etc/ssh/sshd_config
  - echo "Subsystem sftp  /usr/libexec/openssh/sftp-server" >> /etc/ssh/sshd_config
  - echo "PermitRootLogin prohibit-password" >> /etc/ssh/sshd_config
  - echo "GatewayPorts no" >> /etc/ssh/sshd_config
  - echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
  - echo "KbdInteractiveAuthentication no" >> /etc/ssh/sshd_config
  - echo "PrintMotd no" >> /etc/ssh/sshd_config
  - echo "AuthorizedKeysFile .ssh/authorized_keys" >> /etc/ssh/sshd_config
  - echo "HostKey /etc/ssh/ssh_host_rsa_key" >> /etc/ssh/sshd_config
  - echo "HostKey /etc/ssh/ssh_host_ed25519_key" >> /etc/ssh/sshd_config
  - echo "HostKey /etc/ssh/ssh_host_ecdsa_key" >> /etc/ssh/sshd_config
  - echo "KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256" >> /etc/ssh/sshd_config
  - echo "Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr" >> /etc/ssh/sshd_config
  - echo "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com" >> /etc/ssh/sshd_config
  - echo "LogLevel INFO" >> /etc/ssh/sshd_config
  - echo "UseDNS no" >> /etc/ssh/sshd_config
  - systemctl restart sshd
EOT

  master_user_data = <<EOT
#cloud-config
package_update: ${var.perform_system_update}
package_upgrade: ${var.perform_system_update}
write_files:
  - content: |
      ---
      apiVersion: helm.cattle.io/v1
      kind: HelmChartConfig
      metadata:
        name: rke2-cilium
        namespace: kube-system
      spec:
        valuesContent: |-
          kubeProxyReplacement: strict
          k8sServiceHost: ${local.master_ip}
          k8sServicePort: 6443
          tunnel: disabled
          ipv4NativeRoutingCIDR: ${local.network_cidr}
          cni:
            chainingMode: "none"
          operator:
            replicas: 1
    path: /var/lib/rancher/rke2/server/manifests/rke2-cilium-config.yaml
  - content: |
      cni:
        - cilium
      disable-kube-proxy: true
      disable-cloud-controller: true
      node-ip: ${local.master_ip}
      node-external-ip: IP_ADDRESS
      egress-selector-mode: agent
      kubelet-arg:
        - '--cloud-provider=external'
      tls-san:
        - IP_ADDRESS
        - ${local.master_ip}
      node-taint:
        - "CriticalAddonsOnly=true:NoExecute"
    path: /etc/rancher/rke2/config.yaml
runcmd:
  - sed "s/IP_ADDRESS/$(curl https://ifconfig.me)/g" -i /etc/rancher/rke2/config.yaml
${local.configure_ssh}
  - curl -sfL https://get.rke2.io | sh -
  - systemctl enable rke2-server
  - systemctl start rke2-server
EOT

  agent_nodes = merge([
    for pool_idx, pool in var.agent_nodepools : {
      for idx in range(pool.count) :
      format("%s-%s", pool.name, idx + 1) => {
        name : pool.name,
        server_type : pool.server_type,
        location : pool.location,
        ip : "${local.agent_ip_prefix}${pool_idx}.${idx + 1}"
      }
    }
  ]...)

  agent_user_data = <<EOT
#cloud-config
package_update: ${var.perform_system_update}
package_upgrade: ${var.perform_system_update}
write_files:
  - content: |
      server: https://${local.master_ip}:9345
      token: ${ssh_sensitive_resource.node-token.result}
      node-ip: NODE_IP
      node-external-ip: IP_ADDRESS
      kubelet-arg:
        - '--cloud-provider=external'
    path: /etc/rancher/rke2/config.yaml
runcmd:
  - sed "s/IP_ADDRESS/$(curl https://ifconfig.me)/g" -i /etc/rancher/rke2/config.yaml
${join("\n", [for k in split("\n", ssh_sensitive_resource.master-ssh-keys.result) : "  - echo '${k}' >> /root/.ssh/authorized_keys"])}
  - curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -
${local.configure_ssh}
  - systemctl enable rke2-agent.service
  - systemctl start rke2-agent.service
EOT
}
