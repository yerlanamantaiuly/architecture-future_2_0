locals {
  ssh_metadata = "${var.ssh_user}:${var.ssh_public_key}"
}

resource "yandex_compute_disk" "data" {
  name        = "${var.name}-data"
  description = "Подключаемый диск данных для ${var.name}"
  zone        = var.zone
  size        = var.secondary_disk_size
  type        = var.secondary_disk_type
  labels      = var.labels
}

resource "yandex_compute_instance" "this" {
  name                      = var.name
  hostname                  = var.name
  zone                      = var.zone
  platform_id               = var.platform_id
  labels                    = var.labels
  allow_stopping_for_update = var.allow_stopping_for_update

  resources {
    cores         = var.cores
    memory        = var.memory
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.boot_disk_image_id
      size     = var.boot_disk_size
      type     = var.boot_disk_type
    }
  }

  secondary_disk {
    disk_id     = yandex_compute_disk.data.id
    auto_delete = false
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = var.nat
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  metadata = {
    ssh-keys = local.ssh_metadata
  }
}
