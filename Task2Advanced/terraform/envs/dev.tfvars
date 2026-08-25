cloud_id  = "b1gxxxxxxxxxxxxxxxxxxx"
folder_id = "b1g0000000000000000dev"
zone      = "ru-central1-a"

vm_name       = "future20-app"
cores         = 2
memory        = 2
core_fraction = 20
preemptible   = true

image_family        = "ubuntu-2404-lts-oslogin"
boot_disk_size      = 20
secondary_disk_size = 10
secondary_disk_type = "network-hdd"

subnet_id = "e9bxxxxxxxxxxxxxxxxxdev"
nat       = true

ssh_user       = "ubuntu"
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPlaceholderDevPublicKeyDoNotUse future20-dev"

labels = {
  project     = "future20"
  environment = "dev"
  managed_by  = "terraform"
}
