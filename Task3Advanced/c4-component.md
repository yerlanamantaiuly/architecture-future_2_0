# C4: компоненты

Два среза, от которых зависит витрина и отказ от логики в DWH: **портал самообслуживания** и **событийная платформа** (включая мосты Camel/DWH).

## 1. Портал самообслуживания (витрина)

Требование бизнеса: сотрудник строит отчёт по любым срезам **в пределах своего доступа**. Медицинские карты в портал не попадают на уровне контракта данных, а не «договорённости аналитиков».

```mermaid
flowchart TB
  user["Бизнес-пользователь"]

  subgraph portal["Self-service Portal"]
    ui["Web UI / конструктор"]
    gateway["BFF / API gateway"]
    authz["Policy engine<br/>RBAC + ABAC + purpose"]
    semantic["Семантический слой<br/>метрики и срезы"]
    query["Query orchestrator"]
    reports["Каталог готовых отчётов"]
    audit["Access audit"]
  end

  subgraph serving["Serving — без PHI/EMR"]
    clickhouse["OLAP serving<br/>ClickHouse"]
    products["Domain data products"]
  end

  catalog["Data catalog / glossary"]
  iam["IAM / SSO"]
  kms["KMS"]

  user --> ui --> gateway
  gateway --> authz
  authz --> iam
  gateway --> semantic
  gateway --> reports
  semantic --> query --> clickhouse
  products --> clickhouse
  catalog --> semantic
  authz --> audit
  clickhouse --> kms
```

Компоненты и ответственность:

| Компонент | Зачем |
|-----------|--------|
| Policy engine | Роль + атрибуты (`domain`, `legal_entity`, `region`, `purpose=analytics`). Запрет классов `medical.record`, `diagnostic.result`. |
| Семантический слой | Единые KPI («загрузка клиники», «NPL», «time-to-diagnosis» как *срок*, без самого диагноза). |
| Query orchestrator | Только по зарегистрированным продуктам; запрет ad-hoc к сырому озеру. |
| Access audit | Журнал «кто какую витрину строил» — требование ИБ и 152-ФЗ. |
| Domain data products | Владелец — домен, не команда DWH. Контракт, SLO, схема в каталоге. |

ИИ-домен **не** публикует в serving портала эмбеддинги снимков и тексты заключений. Максимум — операционный продукт `ai_sla` (латентность, доля авторазметки).

## 2. Событийная платформа и мосты

```mermaid
flowchart LR
  subgraph producers["Продюсеры доменов"]
    clinical["Clinical services"]
    fintech["FinTech services"]
    ai["AI services"]
    pharma["Pharma gateway"]
    devices["Device gateway"]
  end

  subgraph bus["Event backbone"]
    sdk["Producer SDK<br/>идемпотентность, trace-id"]
    kafka["Kafka / Yandex Managed Kafka"]
    schema["Schema Registry"]
    dlq["DLQ + replay"]
    gov["Governance:<br/>retention, ACL топиков"]
  end

  subgraph bridges["Антикоррупционный слой"]
    cdc["CDC из SQL Server"]
    camelACL["Camel → Event adapter"]
    anti["Anti-corruption translators"]
  end

  subgraph consumers["Потребители"]
    stream["Stream jobs → витрины"]
    portal["Self-service serving"]
    domain["Другие домены"]
  end

  producers --> sdk --> kafka
  schema --> sdk
  kafka --> dlq
  kafka --> gov
  cdc --> anti --> kafka
  camelACL --> anti
  kafka --> stream --> portal
  kafka --> domain
```

Правила, без которых шина снова станет «Camel 2.0»:

1. Контракт события в Schema Registry **до** записи в топик (compatibility BACKWARD).
2. DLQ обязателен на каждом критичном консьюмере; replay — отдельная операция, не «переложить из DWH».
3. CDC и Camel adapter переводят легаси-модель в канонические события, а не тащат таблицы SQL Server в витрину как есть.
4. Синхронные вызовы на критическом пути (клиника ↔ банк ↔ ИИ) к 36 месяцу запрещены политикой архитектуры; исключение — authorization/payment confirm с явным timeout и circuit breaker.

## 3. Компоненты ИБ на стыке медицины и банка

Один человек может быть и пациентом, и заёмщиком. Это **не** повод для единого хранилища ПДн.

- Отдельные ключи KMS на клинический контур и на финтех.
- Согласие (`purpose`) проверяется и при клинике, и при витрине.
- Корреляция клиентских профилей — через токенизированный `party_id`, не через паспорт в Kafka.
- Геораспределение: медданные региона не реплицируются «на всякий случай» в аналитический folder штаб-квартиры.
