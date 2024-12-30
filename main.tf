variable "RCLONE_CONFIG_PASS" {
  type = string
}

locals {
  user_data = sensitive(<<EOF
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
- /root/mirror-sync/syncrepo-template.sh | tee /var/log/arch-sync.log
- rsync -rhLptgoD -S -f 'R .~tmp~' --progress -v rsync://mirror.twds.com.tw/fedora/ /mnt/idrive/fedora --exclude='*aarch64*' --exclude='*i386*' --exclude='*armhfp*'
- curl "https://api.vultr.com/v2/instances/`cat /var/lib/cloud/data/instance-id`" -X DELETE -H "Authorization: Bearer ${var.VULTR_API_KEY}"
EOF
  )
}

resource "vultr_instance" "mirror_sync" {
  label       = "mirror_sync"
  region      = "sgp"
  os_id       = 2284
  plan        = "vc2-2c-4gb"
  hostname    = "mirror-sync"
  enable_ipv6 = true
  ssh_key_ids = ["dc63aac6-5d36-419e-af64-c5ce7fdb3e8e"]
  user_scheme = "limited"

  backups          = "disabled"
  activation_email = false

  user_data = local.user_data
}

