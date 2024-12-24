terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "mirror_sync" {
  ami           = data.aws_ami.ubuntu.id
  key_name      = "primary"
  instance_market_options {
    market_type = "spot"
  }

  instance_type = "c5.large"
  user_data = <<EOF
#cloud-config
runcmd:
- id
- sudo mkdir /mnt/idrive
- sudo -v ; curl https://rclone.org/install.sh | sudo bash
- rclone mount --vfs-cache-mode full --vfs-cache-max-size 10G --transfers 16 idrive:mirror /mnt/idrive
- wget "https://gitlab.archlinux.org/archlinux/infrastructure/-/raw/master/roles/syncrepo/files/syncrepo-template.sh" -O /usr/bin/syncrepo-template
EOF
}
