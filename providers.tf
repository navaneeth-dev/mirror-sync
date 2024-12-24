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

  root_block_device {
    volume_size = 32
  }

  user_data = <<EOF
#cloud-config
write_files:
- content: RCLONE_ENCRYPT_V0: t2fEKG8JdfBc/788/MSmbl+CYcXRU42YvHAS5xlop+87kBEkcfiAay93M4ypi1Pvtft/LREzbSRfN58tXOwKgJbzZ+U7SLluxvZAv8whqQ5tN6mX14wWG+dQk7JARwYNbYUZ3/xd1ztkMmiCeN6Npz1qrxRb5YqQD2XSzCL7uIY6/WdEKpv6rWS+bdvPeo3MP2pcNsr9Ug5yD/X/dcgg4bs3eopVWzJcOGjRfLdN0F/wytXLdCFW5u4ixKgRmPfUQg2vZUN2lMbFi/If355hiTxx4Ax9kvNyE9QHlivUPh6HfCkVwUw+RFFxvsWG3DQ/ulY=
  path: /root/.config/rclone/rclone.conf
runcmd:
- sudo mkdir /mnt/idrive
- sudo -v ; curl https://rclone.org/install.sh | sudo bash
- rclone mount --daemon --vfs-cache-mode full --vfs-cache-max-size 24G --transfers 16 idrive:mirror /mnt/idrive
- wget "https://github.com/navaneeth-dev/mirror-sync/syncrepo-template.sh" -O /usr/bin/syncrepo-template
- chmod +x /usr/bin/syncrepo-template
EOF
}
