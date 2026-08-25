output "instance_id" {
  value = module.vm.instance_id
}

output "instance_name" {
  value = module.vm.instance_name
}

output "internal_ip" {
  value = module.vm.internal_ip
}

output "external_ip" {
  value     = module.vm.external_ip
  sensitive = false
}

output "disk_id" {
  value = module.vm.disk_id
}

output "fqdn" {
  value = module.vm.fqdn
}
