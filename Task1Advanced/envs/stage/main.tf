data "yandex_compute_image" "os" {
  family = var.image_family
}

module "vm" {
  source = "../../modules/vm"

  name                = var.vm_name
  zone                = var.zone
  platform_id         = var.platform_id
  cores               = var.cores
  memory              = var.memory
  core_fraction       = var.core_fraction
  preemptible         = var.preemptible
  boot_disk_image_id  = data.yandex_compute_image.os.id
  boot_disk_size      = var.boot_disk_size
  secondary_disk_size = var.secondary_disk_size
  secondary_disk_type = var.secondary_disk_type
  subnet_id           = var.subnet_id
  nat                 = var.nat
  ssh_user            = var.ssh_user
  ssh_public_key      = var.ssh_public_key
  labels              = var.labels
}
