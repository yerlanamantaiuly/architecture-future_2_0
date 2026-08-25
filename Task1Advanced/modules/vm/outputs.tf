output "instance_id" {
  description = "ID виртуальной машины."
  value       = yandex_compute_instance.this.id
}

output "instance_name" {
  description = "Имя виртуальной машины."
  value       = yandex_compute_instance.this.name
}

output "fqdn" {
  description = "FQDN инстанса в облаке."
  value       = yandex_compute_instance.this.fqdn
}

output "internal_ip" {
  description = "Внутренний IP-адрес."
  value       = yandex_compute_instance.this.network_interface[0].ip_address
}

output "external_ip" {
  description = "Публичный IP-адрес (null, если nat = false)."
  value       = try(yandex_compute_instance.this.network_interface[0].nat_ip_address, null)
}

output "disk_id" {
  description = "ID подключаемого диска данных."
  value       = yandex_compute_disk.data.id
}

output "disk_name" {
  description = "Имя подключаемого диска."
  value       = yandex_compute_disk.data.name
}

output "zone" {
  description = "Зона, в которой размещена ВМ."
  value       = yandex_compute_instance.this.zone
}
