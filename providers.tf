terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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

variable "AWS_ACCESS_KEY_ID" {
  type = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  type = string
}

variable "RCLONE_CONFIG_PASS" {
  type = string
}

provider "aws" {
  region     = "ap-southeast-1"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}
