output "kubeconfig" {
  description = "Kubeconfig in YAML format"
  value       = replace(ssh_sensitive_resource.kubeconfig.result, "127.0.0.1", hcloud_server.master.ipv4_address)
}
