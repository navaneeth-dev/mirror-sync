terraform {
  required_providers {
    linode = {
      source = "linode/linode"
    }
  }

  cloud {
    organization = "dev-test-org"
    hostname     = "app.terraform.io"

    workspaces {
      name = "mirror-sync"
    }
  }
}

variable "RCLONE_CONFIG_PASS" {
  type = string
}

provider "linode" {}
