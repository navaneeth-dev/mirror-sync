terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.23.1"
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

variable "VULTR_API_KEY" {
  type = string
}

provider "vultr" {
  api_key     = var.VULTR_API_KEY
  rate_limit  = 100
  retry_limit = 3
}
