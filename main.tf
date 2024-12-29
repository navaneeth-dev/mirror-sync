resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "linode_instance" "mirror_sync" {
  label           = "mirror_sync"
  image           = "linode/ubuntu22.04"
  region          = "sg-sin-2"
  type            = "g6-standard-2"
  authorized_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICiUB1MgFciQ63LsGGBwHVjCtf1cn50BdxN9jTtfTPGF rize@legion"]
  root_pass       = random_password.password.result

  metadata {
    user_data = base64encode(<<EOF
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
- chmod +x /root/mirror-sync/syncrepo-template.sh
- /root/mirror-sync/syncrepo-template.sh > /var/log/arch-sync.log
- poweroff
EOF
    )
  }

  swap_size  = 256
  private_ip = true
}

