variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "zone" {
  type    = string
  default = "ru-central1-a"
}

variable "image_family" {
  type    = string
  default = "ubuntu-2404-lts-oslogin"
}

variable "vm_name" {
  type = string
}

variable "cores" {
  type = number
}

variable "memory" {
  type = number
}

variable "core_fraction" {
  type    = number
  default = 100
}

variable "platform_id" {
  type    = string
  default = "standard-v3"
}

variable "boot_disk_size" {
  type = number
}

variable "secondary_disk_size" {
  type = number
}

variable "secondary_disk_type" {
  type    = string
  default = "network-hdd"
}

variable "subnet_id" {
  type = string
}

variable "nat" {
  type    = bool
  default = true
}

variable "preemptible" {
  type    = bool
  default = false
}

variable "ssh_user" {
  type    = string
  default = "ubuntu"
}

variable "ssh_public_key" {
  type      = string
  sensitive = true
}

variable "labels" {
  type    = map(string)
  default = {}
}
