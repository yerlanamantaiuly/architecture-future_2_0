# Задание 2. CI/CD и удалённое хранение состояния

Terraform-код живёт в `terraform/`, state — **только** в S3-совместимом хранилище (Yandex Object Storage или локальный MinIO). Локальные `*.tfstate` в git не попадают (корневой `.gitignore`).

```
Task2Advanced/
├── README.md
├── .env.example                 # шаблон секретов, сам .env в gitignore
├── docker-compose.minio.yml     # локальный backend для отладки
├── scripts/tf.sh                # init / plan / apply / destroy
├── ci/github-actions.yml        # копия workflow для ревью
└── terraform/
    ├── versions.tf              # backend "s3" без секретов
    ├── providers.tf
    ├── main.tf                  # тот же vm-модуль, что в Task1
    ├── variables.tf
    ├── outputs.tf
    └── envs/{dev,stage,prod}.tfvars
```

Рабочий GitHub Actions: [`.github/workflows/terraform.yml`](../.github/workflows/terraform.yml) (GitHub читает workflow только из корня репозитория).

## Почему state не локальный

- Несколько инженеров и CI не затирают друг друга.
- State содержит IP и метаданные инфраструктуры — ему место в закрытом бакете с версионированием, не в git.
- На каждое окружение — свой ключ: `envs/dev/terraform.tfstate`, `envs/stage/...`, `envs/prod/...`.

Секреты backend (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) и `YC_TOKEN` передаются переменными окружения / GitHub Secrets, не файлами в репозитории.

## Локальный MinIO (чтобы проверить backend без облака)

```bash
cd Task2Advanced
docker compose -f docker-compose.minio.yml up -d
export AWS_ACCESS_KEY_ID=minioadmin
export AWS_SECRET_ACCESS_KEY=minioadmin
export TF_STATE_BUCKET=future20-tfstate
export TF_STATE_ENDPOINT=http://localhost:9000
# YC_TOKEN всё равно нужен, если plan ходит в Yandex Cloud.
chmod +x scripts/tf.sh
./scripts/tf.sh init  dev
./scripts/tf.sh plan  dev
# apply — только когда осознанно меняете облако:
# ./scripts/tf.sh apply dev
```

`scripts/tf.sh` всегда делает `terraform init -reconfigure` с `-backend-config`, затем `plan`/`apply` с `-var-file=envs/<env>.tfvars`.

## Yandex Object Storage (боевой backend)

1. Бакет `future20-tfstate`, версионирование включено, публичный доступ выключен.
2. Отдельный сервисный аккаунт с `storage.editor` только на этот бакет + `compute.editor` на folder окружения.
3. Статический ключ — в GitHub Secrets, не в tf-файлы.

```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export YC_TOKEN=...
export TF_STATE_BUCKET=future20-tfstate
export TF_STATE_ENDPOINT=https://storage.yandexcloud.net
./scripts/tf.sh plan prod
```

## GitHub Actions

| Событие | Что происходит |
|---------|----------------|
| `pull_request` / `push` в `main` | `fmt` + `terraform init -backend=false` + `validate` (без облачных секретов) |
| `workflow_dispatch` | кнопка **Run workflow**: `plan` или `apply` для выбранного `dev`/`stage`/`prod` |

`apply` **не** запускается сам по push. Только кнопка **Run workflow** с `action=apply`. Job `apply` привязан к GitHub Environment с тем же именем (`dev` / `stage` / `prod`) — на `prod` включаются Required reviewers.

### Секреты репозитория (или Environment)

| Secret | Зачем |
|--------|--------|
| `YC_TOKEN` | провайдер Yandex Cloud |
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` | доступ к бакету state |
| `TF_STATE_BUCKET` | имя бакета |
| `TF_STATE_ENDPOINT` | `https://storage.yandexcloud.net` или URL MinIO |

### Изоляция и безопасность пайплайна

- `permissions: contents: read` — workflow не получает право пушить в репозиторий.
- `TF_IN_AUTOMATION=true`, `TF_INPUT=false` — без интерактива, меньше шума в логах.
- Plan-файл уходит артефактом и применяется как есть: apply не пересчитывает план заново.
- Окружения не шарят state-ключ: ошибка в dev не трогает prod.
- Placeholder-ключи в `*.tfvars` — не боевые. Боевой SSH и folder id лучше хранить в GitHub Environment Variables / Secrets и подставлять `-var=`, не коммитить.
- Приватный SSH и `*.tfstate` в `.gitignore`.

## Соответствие критериям ревью

- Пайплайн: init → plan → apply по кнопке / approval.
- State не локальный.
- Переменные и секреты не зашиты в код.
- Окружения изолированы folder + backend key + GitHub Environment.
