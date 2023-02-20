locals {
  kubeconfig_parsed = yamldecode(local.kubeconfig_external)

  kubeconfig_data = {
    host                   = local.kubeconfig_parsed["clusters"][0]["cluster"]["server"]
    client_certificate     = base64decode(local.kubeconfig_parsed["users"][0]["user"]["client-certificate-data"])
    client_key             = base64decode(local.kubeconfig_parsed["users"][0]["user"]["client-key-data"])
    cluster_ca_certificate = base64decode(local.kubeconfig_parsed["clusters"][0]["cluster"]["certificate-authority-data"])
  }
}

output "kubeconfig" {
  description = "Kubeconfig in YAML format"
  value       = replace(ssh_sensitive_resource.kubeconfig.result, "127.0.0.1", hcloud_server.master.ipv4_address)
}

output "kubeconfig_data" {
  description = "Kubeconfig as structured data to pass values to other provider"
  value       = local.kubeconfig_data
}
