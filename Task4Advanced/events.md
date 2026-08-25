# Каталог доменных событий

Минимальный контракт — то, что обязано быть в Schema Registry. ПДн в value не кладём: идентификаторы-сурогаты, суммы, статусы, ссылки.

Общие заголовки всех событий: `event_id`, `event_type`, `occurred_at`, `producer`, `trace_id`, `schema_version`.

| Событие | Контекст-источник | Семантика | Минимальный контракт (payload) |
|---------|-------------------|-----------|--------------------------------|
| `PartyRegistered` | Party & Consent | Появилась сторона (пациент и/или клиент банка) | `party_id`, `registered_at` |
| `ConsentGranted` | Party & Consent | Дано согласие на цель | `consent_id`, `party_id`, `purpose`, `valid_to` |
| `ConsentRevoked` | Party & Consent | Согласие отозвано | `consent_id`, `party_id`, `purpose`, `revoked_at` |
| `AppointmentScheduled` | Patient Flow | Запись на слот | `appointment_id`, `party_id`, `clinic_id`, `slot_from`, `slot_to`, `physician_id` |
| `AppointmentCompleted` | Patient Flow | Визит состоялся | `appointment_id`, `party_id`, `clinic_id`, `completed_at` |
| `AppointmentNoShow` | Patient Flow | Неявка | `appointment_id`, `clinic_id` |
| `CaseOpened` | Care Delivery | Открыт случай | `case_id`, `party_id`, `clinic_id`, `appointment_id?` |
| `StudyOrdered` | Care Delivery | Назначено исследование (в т.ч. ИИ) | `order_id`, `case_id`, `study_type`, `inference_required` |
| `AiInferenceCompleted` | AI Diagnostics | ИИ завершил обработку | `inference_id`, `order_id`, `model_version`, `status`, `artifact_ref` |
| `InvoiceIssued` | Billing | Выставлен счёт за услугу | `invoice_id`, `party_id`, `amount`, `currency`, `appointment_id?` |
| `PaymentReceived` | Billing | Счёт оплачен | `invoice_id`, `amount`, `paid_at`, `channel` |
| `CreditApplicationSubmitted` | Lending | Заявка на кредит | `application_id`, `party_id`, `product_code`, `amount` |
| `CreditApplicationDecided` | Lending | Решение по заявке | `application_id`, `decision`, `decided_at` |
| `CreditContractCreated` | Lending | Создан кредитный договор | `contract_id`, `application_id`, `party_id`, `principal`, `rate` |
| `CreditWentDelinquent` | Lending | Выход на просрочку | `contract_id`, `dpd`, `outstanding` |
| `AccountOpened` | Banking Accounts | Открыт счёт | `account_id`, `party_id`, `product_code` |
| `LedgerPosted` | Banking Accounts | Проведена операция | `account_id`, `entry_id`, `amount`, `direction` |
| `StockDepleted` | Clinic Supply | Остаток ниже порога | `sku`, `clinic_id`, `quantity`, `min_level` |
| `LotExpired` | Clinic Supply | Партия просрочена | `sku`, `lot`, `clinic_id` |
| `DataProductPublished` | Data Mesh Platform | Зарегистрирована новая версия витрины | `product_id`, `version`, `owner_domain`, `schema_ref` |
| `DrugSupplyRegistered` | Pharma | Поставка / серия принята | `lot`, `sku`, `qty`, `partner_id` |
| `RecallIssued` | Pharma | Отзыв серии | `lot`, `sku`, `reason_code` |
| `DeviceCalibrated` | MedTech Devices | Прибор поверен | `device_id`, `clinic_id`, `valid_to` |

`AiInferenceCompleted.artifact_ref` указывает в закрытый imaging store. Консьюмерам витрины это поле **не отдаётся** (отдельный derived event / продукт `ai_sla` без ref).
