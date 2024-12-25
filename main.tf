resource "aws_instance" "mirror_sync" {
  ami           = "ami-0f7e0b5dcc8774b11"
  key_name      = "primary"
  instance_market_options {
    market_type = "spot"
  }

  instance_type = "m6g.large"

  tags = {
    Name = "mirror-sync"
  }

  root_block_device {
    volume_size = 32
  }

  user_data = <<EOF
#cloud-config
package_update: true
packages:
  - zsh
write_files:
- content: |
    RCLONE_ENCRYPT_V0:
    t2fEKG8JdfBc/788/MSmbl+CYcXRU42YvHAS5xlop+87kBEkcfiAay93M4ypi1Pvtft/LREzbSRfN58tXOwKgJbzZ+U7SLluxvZAv8whqQ5tN6mX14wWG+dQk7JARwYNbYUZ3/xd1ztkMmiCeN6Npz1qrxRb5YqQD2XSzCL7uIY6/WdEKpv6rWS+bdvPeo3MP2pcNsr9Ug5yD/X/dcgg4bs3eopVWzJcOGjRfLdN0F/wytXLdCFW5u4ixKgRmPfUQg2vZUN2lMbFi/If355hiTxx4Ax9kvNyE9QHlivUPh6HfCkVwUw+RFFxvsWG3DQ/ulY=
  path: '/root/.config/rclone/rclone.conf'
runcmd:
- sudo mkdir /mnt/idrive
- sudo -v ; curl https://rclone.org/install.sh | sudo bash -s beta
- RCLONE_CONFIG_PASS='${var.RCLONE_CONFIG_PASS}' rclone mount --links --daemon --vfs-cache-mode full --vfs-cache-max-size 24G --transfers 8 idrive:mirror /mnt/idrive
- git clone https://github.com/navaneeth-dev/mirror-sync /root/mirror-sync
- chmod +x /root/mirror-sync/syncrepo-template
EOF
}
