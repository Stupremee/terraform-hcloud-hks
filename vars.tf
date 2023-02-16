variable "hcloud_token" {
  description = "The token for accessing the Hetzner API"
  type        = string
}

variable "prefix" {
  description = "Common prefix for all services"
  type        = string
}

variable "labels" {
  description = "Hetzner Labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "ssh_public_keys" {
  description = "The ssh public keys which can be used to connect to the nodes"
  type        = map(string)
  default     = {}
}

variable "perform_system_update" {
  type        = bool
  description = "If set to true, a system update will be performed on each node before starting RKE2"
}

variable "network_zone" {
  description = "Zone for all the networks"
  type        = string
}

variable "ssh_port" {
  description = "The main SSH port to connect to the nodes"
  type        = number
  default     = 22

  validation {
    condition     = var.ssh_port >= 0 && var.ssh_port <= 65535
    error_message = "The SSH port must use a valid range from 0 to 65535"
  }
}

variable "master_node" {
  description = "List of nodepools which will serve as a master"
  type = object({
    name        = string
    server_type = string
    location    = string
  })
}

variable "agent_nodepools" {
  description = "List of nodepools used as agents in the cluster"
  type = list(object({
    name        = string
    server_type = string
    location    = string
    count       = number
  }))
}

variable "cert-manager" {
  description = "Option for customizing the cert-manager instance that will be deployed"
  type = object({
    email = string
  })
}

variable "loadbalancer" {
  description = "Configure the Load Balancer that will be created"
  type = object({
    type     = string
    location = string
  })
}
