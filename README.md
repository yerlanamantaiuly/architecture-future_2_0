# architecture-future_2_0

Проектная работа 11 спринта курса «Архитектор ПО»: целевая архитектура и инфраструктура компании «Будущее 2.0».

Решение сдаётся **одним пул-реквестом**. Каждое задание лежит в своей директории:

| Директория | Содержание |
|------------|------------|
| [Task1Advanced](Task1Advanced/) | Переиспользуемый Terraform-модуль VM и три окружения (dev / stage / prod) |
| [Task2Advanced](Task2Advanced/) | Удалённый backend (S3/MinIO) и CI/CD (GitHub Actions) |
| [Task3Advanced](Task3Advanced/) | C4 (контейнеры и компоненты), карта рисков, план управления рисками |
| [Task4Advanced](Task4Advanced/) | Bounded contexts, агрегаты, Event Storming, обоснование EDA |
| [Task5Advanced](Task5Advanced/) | Техрадар, TCO на 3 года, роадмап Data Mesh |

## Как смотреть

- Terraform: `Task1Advanced/README.md` и `Task2Advanced/README.md`.
- Архитектура: mermaid-диаграммы рендерятся на GitHub в markdown-файлах.
- CI: рабочий workflow — [`.github/workflows/terraform.yml`](.github/workflows/terraform.yml); копия для ревью — `Task2Advanced/ci/github-actions.yml`.
