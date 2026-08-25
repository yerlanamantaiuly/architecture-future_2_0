cloud_id  = "b1gxxxxxxxxxxxxxxxxxxx"
folder_id = "b1g000000000000000prod"
zone      = "ru-central1-a"

vm_name       = "future20-app"
cores         = 4
memory        = 8
core_fraction = 100
preemptible   = false
platform_id   = "standard-v3"

image_family        = "ubuntu-2404-lts-oslogin"
boot_disk_size      = 50
secondary_disk_size = 200
secondary_disk_type = "network-ssd"

subnet_id = "e9bxxxxxxxxxxxxxxxxprod"
nat       = false

ssh_user       = "ubuntu"
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPlaceholderPrdPublicKeyDoNotUse future20-prod"

labels = {
  project     = "future20"
  environment = "prod"
  managed_by  = "terraform"
}
