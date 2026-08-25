# Задание 1. Модульная инфраструктура для нескольких сред

Универсальный модуль `vm_module` (`modules/vm/`) поднимает виртуальную машину Yandex Cloud с подключаемым диском. Модуль **не знает** про dev/stage/prod: все различия приходят переменными из корня окружения.

```
Task1Advanced/
├── README.md
├── modules/vm/
│   ├── main.tf          # ВМ + secondary disk + NIC
│   ├── variables.tf     # интерфейс модуля
│   ├── outputs.tf       # id, IP, имя, disk_id, fqdn
│   └── versions.tf
└── envs/
    ├── dev/
    ├── stage/
    └── prod/
```

Каждое окружение — отдельный root-модуль со своим `terraform.tfvars`. Так изолируются state, folder и параметры железа.

## Интерфейс модуля

| Переменная | Назначение | Обязательная |
|------------|------------|--------------|
| `cores` | число vCPU | да |
| `memory` | RAM, ГБ | да |
| `secondary_disk_size` / `secondary_disk_type` | подключаемый диск | да / нет (default HDD) |
| `subnet_id` | подсеть | да |
| `ssh_public_key` | публичный SSH-ключ | да |
| `name`, `zone`, `boot_disk_image_id` | идентификация и образ | да |
| `platform_id`, `core_fraction`, `preemptible`, `nat`, `labels` | опции | нет |

`image_id` в модуль передаётся снаружи: окружение резолвит семейство образа через `data.yandex_compute_image`, чтобы в модуле не было захардкоженных ID.

## Выходы

`instance_id`, `instance_name`, `internal_ip`, `external_ip`, `disk_id`, `disk_name`, `fqdn`, `zone`.

## Конфигурации окружений

| Параметр | dev | stage | prod |
|----------|-----|-------|------|
| vCPU / RAM | 2 / 2 ГБ | 2 / 4 ГБ | 4 / 8 ГБ |
| boot / data disk | 20 / 10 ГБ | 30 / 50 ГБ | 50 / 200 ГБ |
| core_fraction | 20% | 50% | 100% |
| preemptible | true | false | false |
| диск данных | network-hdd | network-hdd | network-ssd |
| folder / subnet | свои ID | свои ID | свои ID |

Подставьте реальные `cloud_id`, `folder_id`, `subnet_id` и свой публичный ключ в `terraform.tfvars`. Приватные ключи в репозиторий не кладутся (см. корневой `.gitignore`).

## Как применить

Нужны Terraform ≥ 1.5, провайдер `yandex-cloud/yandex` и авторизация (`yc config` или `YC_TOKEN` / ключ сервисного аккаунта).

Из **корня окружения**:

```bash
cd Task1Advanced/envs/dev
terraform init
terraform plan  -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Stage и prod — те же команды из `envs/stage` и `envs/prod`. Именно `-var-file=` подставляет разные параметры в один и тот же модуль.

Пример с явным файлом из любой директории:

```bash
cd Task1Advanced/envs/prod
terraform init
terraform apply -var-file=./terraform.tfvars
```

Уничтожение:

```bash
terraform destroy -var-file=terraform.tfvars
```

## Почему так, а не три копипасты main.tf

- Модуль описывает **ресурсный контракт** (CPU, RAM, диск, сеть, SSH).
- Окружение описывает **политику** (дешёвая прерываемая ВМ vs гарантированные ядра, размер диска, labels.environment).
- Сеть (`subnet_id`) не создаётся внутри модуля: модуль переиспользуем в уже существующих VPC доменов клиник, банка и ИИ.
