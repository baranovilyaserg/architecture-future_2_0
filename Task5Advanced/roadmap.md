# Roadmap — 3-летний план трансформации

## Фазовая трансформация (36 месяцев)

| Фаза | Период | Домены | Ключевые Результаты | Команда | Бюджет | Риски |
|-----|--------|--------|------------------|--------|--------|-------|
| **Фаза 1: пилот** | Месяцы 0-6 | Fintech, Clinics | Kafka Topics (10+), PostgreSQL Event Store готов, Snowflake read layer, 2 домена на Event-Driven | 4 Data Engineers, 2 Platform Engineers, 1 Architect | 2.0M | Сложность интеграции ESB, эволюция схемы |
| **Фаза 2: масштабирование** | Месяцы 6-18 | AI Ops, Analytics, Platform | Все 5 доменов на Kafka, DLQ реализован, каталог Data Mesh запущен, Stream analytics работает | 8 Data Engineers, 3 Platform Engineers, 1 Data Mesh Lead, 2 BI Analysts | 3.5M | Узкое место governance, затраты Snowflake, дефицит навыков |
| **Фаза 3: завершение legacy** | Месяцы 18-36 | (все) | Camel/DWH только чтение, Vitrine (Snowflake self-serve) полностью, аналитика в реальном времени, 99.99% uptime | 6 Data Engineers, 2 Platform Engineers, 3 BI/Analytics, 1 Ops Lead | 2.8M | Проблемы качества данных, задержки аудитов соответствия |

---

## Детальный Roadmap по кварталам

### Квартал 1-2 (Месяцы 0-6): Пилот Fintech + Clinics

| Задача | Статус | Deadline | Ответственный | Метрика |
|--------|--------|----------|-------|---------|
| **Настройка инфраструктуры** | Начало | M2 | Platform Eng | Аккаунт AWS, VPC, группы безопасности |
| - Kafka кластер (3-node, Confluent Cloud) | - | M1 | Platform Eng | Uptime 99.99% |
| - PostgreSQL Event Store (RDS) | - | M1 | DBA | Задержка репликации <100ms |
| - Snowflake аккаунт + IAM | - | M1 | Data Eng Lead | Выполнение запроса <2s |
| **Проектирование схемы событий** | Начало | M3 | Architect | Avro v1.0 для 10 событий |
| - События Fintech (payment, balance, credit) | - | M2 | Fintech Eng + Data Eng | Schema Registry, версионирование |
| - События Clinics (patient, visit, capacity) | - | M2 | Clinics Eng + Data Eng | Доменный контракт, без медицинских записей |
| **Kafka Topics & Producer** | Начало | M4 | Data Eng | 10+ topics live, 1000 msgs/sec |
| - Fintech payment домен → Kafka | - | M3 | Fintech Eng | SLA <100ms publish |
| - Clinics домен → Kafka | - | M3 | Clinics Eng | SLA <500ms publish |
| **Event Store (PostgreSQL)** | Начало | M5 | DBA | 10k events/day сохраняется |
| - Дизайн неизменяемой лог-таблицы | - | M2 | Data Eng Lead | Схема финализирована |
| - Pipeline приёма (Kafka → PG) | - | M4 | Data Eng | DLQ для ошибочных сообщений |
| **Snowflake Read Layer** | Начало | M6 | BI Eng | Fintech + Clinics marts готовы |
| - Fintech marts (transactions, balances) | - | M5 | BI Analyst | <5 min задержка от события |
| - Clinics marts (patient, visit) | - | M5 | BI Analyst | <10 min задержка, без медицинских данных |
| **Checkpoint соответствия** | Начало | M4 | Security | PCI-DSS для Fintech, HIPAA для Clinics |
| - Шифрование данных (TLS, KMS) | - | M3 | Security | Аудит trail готов |
| - RBAC в Snowflake | - | M4 | Data Eng | Роли для каждого домена |
| - Политики хранения данных | - | M4 | Compliance | 7 лет финтех, архив медикарт |

**Критерии выхода (M6)**:
- Fintech домен: 50k платежей/день в Kafka → PostgreSQL → Snowflake
- Clinics домен: 500 визитов/день в Kafka → PostgreSQL → Snowflake
- SLA: задержка <100ms (Kafka), <1 сек (Event Store), <5 min (Snowflake)
- Документация Event Storming для 10 событий
- Пилот успешен, бизнес одобрил масштабирование

---

### Квартал 3-6 (Месяцы 6-18): масштабирование на AI Ops + Analytics + Platform

| Задача | Статус | Deadline | Owner | Метрика |
|--------|--------|----------|-------|---------|
| **Масштабирование Kafka** | Start | M12 | Platform Eng | 20+ topics, multi-region ready |
| - AI Ops events (model, inference) | - | M9 | AI Ops Eng + Data Eng | <1ms SLA per inference |
| - Analytics events (reports, alerts) | - | M10 | Analytics Eng | <5 sec latency |
| - Platform events (health, SLA) | - | M11 | Ops Eng | Real-time monitoring |
| **Event Sourcing & DLQ** | Start | M10 | Data Eng Lead | All 18 events with retry logic |
| - DLQ topics + dead letter handlers | - | M8 | Data Eng | Max retries 3, 24h TTL |
| - Event replay capability | - | M10 | Data Eng | Recovery from failures |
| **Data Mesh Governance** | Start | M14 | Data Mesh Lead | Catalog, ownership, SLA per product |
| - Data product registry (5 domains) | - | M12 | Data Mesh Lead | Each domain owns 1-2 products |
| - Discovery portal (Datacatalog/Atlas) | - | M14 | Data Eng | Lineage tracking |
| - Domain SLA contracts | - | M12 | Arch | Freshness, completeness, uniqueness |
| **Stream Analytics** | Start | M15 | Analytics Eng | Real-time KPI dashboard |
| - Kafka Streams aggregations (5-min windows) | - | M12 | Data Eng | <1 sec aggregation latency |
| - Apache Flink for complex joins | - | M14 | Analytics Eng | 3+ domain event correlations |
| **Anti-Corruption Layers (ACL)** | Start | M16 | Architect | Camel ↔ Kafka adapters |
| - Fintech ACL (DWH → Kafka bridge) | - | M12 | Integration Eng | Legacy reads, new writes to Kafka |
| - Clinics ACL (PowerBuilder → API) | - | M13 | Integration Eng | Operator calls via REST |
| - AI Ops ACL (Python → Event producer) | - | M14 | AI Ops Eng | Inference events async |
| **Compliance Expansion** | Start | M12 | Security | HIPAA, PCI-DSS, GDPR for all |
| - Data masking for Snowflake | - | M10 | Security | PII hashing, redaction policies |
| - Audit logging (CloudTrail + Events) | - | M11 | Ops Eng | 7-year retention |
| - Access control review | - | M16 | Security | Quarterly PAM audits |

**Exit Criteria (M18)**:
- 5 доменов (Fintech, Clinics, AI Ops, Analytics, Platform) публикуют события
- 18 событий в каталоге с contracts
- Data Mesh products: по 1-2 на домен (5-10 total)
- Snowflake read layer актуальна в <5 min
- Stream analytics работает в real-time (KPI dashboard live)
- DLQ + retry logic cover 99.9% success rate

---

### Квартал 7-9 (Месяцы 18-36): Sunset Legacy, Full Event-Driven

| Задача | Статус | Deadline | Owner | Метрика |
|--------|--------|----------|-------|---------|
| **Decommission Legacy Systems** | Start | M30 | Ops Eng | Camel, DWH, PowerBuilder sunset |
| - SQL Server 2008 → archive (S3) | - | M24 | DBA | Read-only mode (M18-24), then archive |
| - Camel ESB → maintenance mode | - | M24 | Integration Eng | ESB routing deprecated, ACLs only |
| - PowerBuilder → REST API only | - | M30 | UI Eng | Legacy UI legacy, new APIs live |
| - Power BI → Snowflake dashboards | - | M30 | BI Lead | Self-serve Vitrine fully adopted |
| **Vitrine Self-Service BI** | Start | M28 | BI Lead | 100% end-user adoption |
| - Snowflake Vitrine fully operational | - | M24 | Data Eng | All 5-10 data products live |
| - BI tool (Superset/Metabase) deployed | - | M26 | BI Eng | Ad-hoc queries, reports, dashboards |
| - RBAC per user role (domain, cost center) | - | M28 | Security | 500+ concurrent users <2s query |
| **Event Store Optimization** | Start | M24 | Data Eng Lead | Real-time event replay, time-travel |
| - PostgreSQL partitioning (по домену, дате) | - | M20 | DBA | Запрос <500ms на 100M событиях |
| - Политики очистки Event Store | - | M22 | Ops | Архив >30 дней на S3 |
| - Time-travel аналитика (воспроизведение событий) | - | M28 | Data Eng | Полный аудит trail для соответствия |
| **Наблюдаемость и мониторинг** | Начало | M24 | Platform Eng | OpenTelemetry, Datadog, SLA dashboards |
| - Распределённое трассирование (end-to-end задержка) | - | M22 | Ops Eng | P99 задержка <500ms все пути |
| - Метрики (events/sec, lag, errors) | - | M22 | Data Eng | Dashboard мониторинга в реальном времени |
| - Playbooks ответа на инциденты | - | M26 | Ops Lead | MTTR <15 min, RTO <1 час |
| **Обучение и документация** | Начало | M20 | Arch | Сертификация команды, runbooks |
| - Сертификация Data Engineer (Kafka, Snowflake) | - | M18 | HR | 100% охват, ежегодное обновление |
| - Runbooks для ответа на инциденты | - | M24 | Ops | Ротация on-call, пути эскалации |
| - Записи архитектурных решений (ADR) | - | M30 | Arch | Паттерны дизайна, документированы trade-offs |
| **Финальный аудит соответствия и безопасности** | Начало | M28 | Security | Сертификация готова |
| - SOC 2 Type II аудит | - | M30 | Security | Cloud-native security baseline |
| - HIPAA пересертификация (Clinics) | - | M30 | Compliance | Резидентность данных, BAA соглашения |
| - PCI-DSS пересертификация (Fintech) | - | M30 | Compliance | Шифрование, токенизация, мониторинг |

**Критерии выхода (M36)**:
- Camel/DWH полностью выведены из эксплуатации (только архивы чтения)
- 100% доменов на Event-Driven архитектуре
- Vitrine self-serve BI: 80%+ усыновление пользователями
- SLA: 99.99% uptime, <100ms критический путь, <5min аналитика задержка
- TCO снижен до 9.8M/год (-40% vs базовое)
- Время выхода на рынок для новых функций: 1-2 недели vs 2-3 месяца
- Полный аудит trail для соответствия (7 лет хранения)

---

## Роли и ответственность

| Роль | FTE | Ответственность | Навыки |
|-----|-----|-----------------|--------|
| **Data Mesh Lead** | 1 | Governance, каталог продуктов, контракты SLA | DDD, governance, SQL |
| **Senior Data Engineer** | 2 | Kafka, PostgreSQL Event Store, дизайн схемы | Kafka, streaming, Python/Java |
| **Data Engineer** | 4-6 | Producers, consumers, Snowflake pipelines, dbt | Kafka, cloud SQL, dbt, Python |
| **Platform Engineer / DevOps** | 2-3 | Инфраструктура, Terraform, мониторинг, on-call | AWS, Terraform, observability |
| **BI Engineer / Analyst** | 2-3 | Snowflake запросы, Vitrine dashboards, dbt | SQL, BI tools, Snowflake |
| **Solutions Architect** | 1 | Дизайн, стратегия миграции, технические решения | Event-Driven, DDD, оценка рисков |
| **Security/Compliance Lead** | 1 | Governance данных, шифрование, аудит, compliance | Security, HIPAA, PCI-DSS, GDPR |
| **Ops / SRE** | 1 | Ответ на инциденты, мониторинг, runbooks | AWS, Kubernetes, observability |

---

## Критерии успеха на каждый этап

### Фаза 1 (M6)
- 2 домена полностью operational на Event-Driven
- Event Sourcing с 99.99% доставкой
- Навыки команды: Kafka + Snowflake сертифицировано (50%)
- Затраты: по бюджету (2.0M ±10%)

### Фаза 2 (M18)
- 5 доменов, 18 событий, каталог Data Mesh live
- Stream analytics KPI dashboard работает
- Snowflake Vitrine готов для пилота с бизнесом
- Команда полностью обучена (100% Kafka/Snowflake)
- Затраты: 3.5M реализовано

### Фаза 3 (M36)
- Legacy системы архивированы
- Vitrine усыновление >80%
- TCO сбережения 19.4M (накопительно)
- SLA выполнены (99.99% uptime)
- Команда готова к BAU операциям
