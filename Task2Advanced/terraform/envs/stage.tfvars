cloud_id  = "b1gxxxxxxxxxxxxxxxxxxx"
folder_id = "b1g00000000000000stage"
zone      = "ru-central1-a"

vm_name       = "future20-app"
cores         = 2
memory        = 4
core_fraction = 50
preemptible   = false

image_family        = "ubuntu-2404-lts-oslogin"
boot_disk_size      = 30
secondary_disk_size = 50
secondary_disk_type = "network-hdd"

subnet_id = "e9bxxxxxxxxxxxxxxxstage"
nat       = true

ssh_user       = "ubuntu"
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPlaceholderStgPublicKeyDoNotUse future20-stage"

labels = {
  project     = "future20"
  environment = "stage"
  managed_by  = "terraform"
}
