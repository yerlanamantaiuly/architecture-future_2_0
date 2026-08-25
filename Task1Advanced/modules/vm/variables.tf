variable "name" {
  description = "Имя виртуальной машины. Не должно содержать имён окружений внутри модуля — значение приходит снаружи."
  type        = string
}

variable "zone" {
  description = "Зона доступности Yandex Cloud (например, ru-central1-a)."
  type        = string
}

variable "platform_id" {
  description = "Платформа вычислительных ресурсов."
  type        = string
  default     = "standard-v3"
}

variable "cores" {
  description = "Количество ядер vCPU."
  type        = number

  validation {
    condition     = var.cores >= 2 && var.cores <= 32 && var.cores % 2 == 0
    error_message = "cores должен быть чётным числом в диапазоне 2..32."
  }
}

variable "memory" {
  description = "Объём RAM в ГБ."
  type        = number

  validation {
    condition     = var.memory >= 1 && var.memory <= 256
    error_message = "memory должен быть в диапазоне 1..256 ГБ."
  }
}

variable "core_fraction" {
  description = "Гарантированная доля vCPU, % (20, 50 или 100)."
  type        = number
  default     = 100

  validation {
    condition     = contains([20, 50, 100], var.core_fraction)
    error_message = "core_fraction: 20, 50 или 100."
  }
}

variable "preemptible" {
  description = "Прерываемая ВМ (дешевле, не для prod)."
  type        = bool
  default     = false
}

variable "boot_disk_image_id" {
  description = "ID образа загрузочного диска. Выбирается в корне окружения (data source), не хардкодится в модуле."
  type        = string
}

variable "boot_disk_size" {
  description = "Размер загрузочного диска, ГБ."
  type        = number
  default     = 20
}

variable "boot_disk_type" {
  description = "Тип загрузочного диска."
  type        = string
  default     = "network-ssd"
}

variable "secondary_disk_size" {
  description = "Размер подключаемого (дополнительного) диска, ГБ."
  type        = number
}

variable "secondary_disk_type" {
  description = "Тип подключаемого диска."
  type        = string
  default     = "network-hdd"
}

variable "subnet_id" {
  description = "ID подсети, в которую подключается ВМ."
  type        = string
}

variable "nat" {
  description = "Выдавать ли публичный IP (NAT)."
  type        = bool
  default     = true
}

variable "ssh_user" {
  description = "Linux-пользователь для SSH."
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "Публичный SSH-ключ (содержимое *.pub), без приватных ключей в репозитории."
  type        = string
  sensitive   = true
}

variable "labels" {
  description = "Метки ресурса. Окружение (dev/stage/prod) передаётся сюда снаружи, модуль его не знает."
  type        = map(string)
  default     = {}
}

variable "allow_stopping_for_update" {
  description = "Разрешить остановку ВМ при изменении CPU/RAM."
  type        = bool
  default     = true
}
