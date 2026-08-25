# Агрегаты

Агрегат — граница согласованности. Событие публикуется **после** успешного изменения агрегата (outbox). Чужой агрегат не меняется в той же транзакции.

## Care Delivery

### Medical Case (случай / карта в рамках обращения)

- **Ключ:** `case_id` (внутри клиники), внешние ссылки: `patient_party_id`, `clinic_id`.
- **Граница:** назначения, записи в карту, статусы исследований по этому случаю. Не включает слоты расписания и не включает бинарные снимки (они в Imaging Store за ссылкой).
- **Инварианты:** нельзя закрыть случай без автора и причины; нельзя добавить запись без действующего согласия `purpose=treatment`; случай принадлежит одной клинике-юрлицу.
- **События:** `CaseOpened`, `CaseNoteAdded`, `CaseClosed`. `CaseNoteAdded` **не** уходит в витрину.

Снимки и DICOM — не часть агрегата (размер и другой lifecycle). Агрегат хранит `artifact_ref`.

## Patient Flow

### Appointment

- **Ключ:** `appointment_id`
- **Граница:** слот, пациент, врач, статус (booked / arrived / completed / no-show / cancelled).
- **Инварианты:** один слот — один активный appointment; завершение визита требует `arrived`.
- **События:** `AppointmentScheduled`, `AppointmentCompleted`, `AppointmentNoShow`.

## Clinic Supply

### StockItem (остаток номенклатуры на складе клиники)

- **Ключ:** `stock_item_id` (`clinic_id` + `sku` + `lot`)
- **Инварианты:** количество ≥ 0; отпуск ниже min_level порождает событие, а не молчаливый минус; просроченная партия не отпускается.
- **События:** `StockIssued`, `StockDepleted`, `LotExpired`.

## Party & Consent

### Party

- **Ключ:** `party_id` (сурогат, не паспорт)
- **Граница:** идентификаторы и роли (пациент, заёмщик) как *факты связи*, без данных карты и без кредитного досье.
- **Инварианты:** персональные атрибуты шифруются; удаление/ограничение по 152-ФЗ каскадирует согласия.

### Consent

- **Ключ:** `consent_id`
- **Инварианты:** есть `purpose`, срок, сторона-оператор; отзыв немедленный для новой обработки.
- **События:** `PartyRegistered`, `ConsentGranted`, `ConsentRevoked`.

## Lending

### Credit Application / Credit Contract

- **Ключ заявки:** `application_id`; **договора:** `contract_id`
- **Граница:** заявка, решение, договор, график. Не включает клинические данные.
- **Инварианты:** договор создаётся только из одобренной заявки; изменение лимита — новая команда, не UPDATE «тихо»; просрочка считается по каноническому календарю банка.
- **События:** `CreditApplicationSubmitted`, `CreditApplicationDecided`, `CreditContractCreated`, `CreditWentDelinquent`.

## Banking Accounts

### Account

- **Ключ:** `account_id`
- **Инварианты:** проводки парные; баланс не уходит ниже овердрафтного инварианта продукта.
- **События:** `AccountOpened`, `LedgerPosted`.

## Billing

### Invoice (счёт за медицинскую услугу или сервис)

- **Ключ:** `invoice_id`
- **Инварианты:** сумма ≥ 0; оплата не больше выставленного; нельзя выставить счёт без `VisitCompleted` или явной услуги.
- **События:** `InvoiceIssued`, `PaymentReceived` (факт оплаты счёта клиники — не путать с `LedgerPosted`).

## AI Diagnostics

### Inference Request

- **Ключ:** `inference_id`
- **Граница:** заказ, модель, статус, ссылка на артефакт. Результат (заключение) хранится в ИИ-контуре, в событии наружу — статус и ссылка для Care Delivery.
- **Инварианты:** инференс только при согласии `purpose=diagnostics`; модель зафиксирована (`model_version`); payload снимка не в шине.
- **События:** `StudyOrdered`, `AiInferenceCompleted`.

## Pharma / MedTech (целевые)

### SupplyAgreement / Device

- Ключи: `agreement_id`, `device_id`
- События: `DrugSupplyRegistered`, `RecallIssued`, `DeviceCalibrated`, `DeviceTelemetryAnomaly` (аномалия прибора — эксплуатация, не диагноз пациента).

## Правила публикации в Mesh

Агрегат может эмитить событие, но **data product** — отдельный контракт: агрегация, обезличивание, SLO. EMR-агрегат не имеет права регистрировать продукт с полями карты.
