terraform {
  required_version = ">= 1.3.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.36.2"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }

    ssh = {
      source  = "loafoe/ssh"
      version = "2.6.0"
    }
  }
}

