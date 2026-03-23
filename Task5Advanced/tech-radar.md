# Tech Radar — Оценка технологий

## Стратегия: Event-Driven Data Mesh на облаке (AWS)

| Статус | Технология | Категория | Обоснование | Срок |
|--------|-----------|----------|-------------|------|
| **ADOPT** | Kafka / Confluent Cloud | Message Bus | Масштабируемая event streaming, Schema Registry, 99.99% uptime | Сейчас |
| **ADOPT** | PostgreSQL 15+ | Event Store | Append-only events, ACID, audit trail, низкие затраты на лицензии | Сейчас |
| **ADOPT** | Snowflake | Data Lake & Vitrine | Multi-cloud, zero-copy sharing, separation compute/storage, 100% PCI-compliant | Сейчас |
| **ADOPT** | AWS S3 | Object Storage | Cheap, durable, GDPR-compliant, lifecycle policies для архива медикарт | Сейчас |
| **ADOPT** | Redis / Elasticache | Cache Layer | In-memory, sub-ms latency для hot reads (балансы, метрики) | Сейчас |
| **ADOPT** | Docker / ECS | Container Orchestration | AWS-native, auto-scaling, CloudWatch integration | Сейчас |
| **ADOPT** | Terraform + GitOps | IaC | Reproducible, версионируется, CI/CD gates | Сейчас |
| **TRIAL** | Event Sourcing Pattern | Architecture | Immutable events для audit (финсектор, медсектор). Риск: eventual consistency | 0-6м |
| **TRIAL** | Data Mesh (Domain-Driven) | Data Architecture | Self-serve data products по доменам. Риск: governance overhead | 6-18м |
| **TRIAL** | Apache Flink / Kafka Streams | Stream Processing | Real-time aggregations, windowing (min-by-min метрики). Альтернатива: AWS Kinesis | 6-18м |
| **TRIAL** | DLT (Delta Lake) или Iceberg | Data Format | Time-travel, schema evolution, compaction. Избегаем Parquet fragmentation | 12-24м |
| **ASSESS** | Temporal + durable execution | Orchestration | Long-running workflows (миграция, заполнение Vitrine). Альтернатива: Step Functions | 18-36м |
| **ASSESS** | OpenTelemetry + Datadog | Observability | Distributed tracing, metrics, logs в одном месте. Альтернатива: ELK | 18-36м |
| **ASSESS** | Apache Superset | BI Tool | Open-source, self-hosted витрина, RBAC, SQL-native. Параллель: Metabase | 24-36м |
| **HOLD** | Apache Camel (ESB) | Legacy Integration | Заменяем на Kafka + ACL слои. Миграция через Strangler Fig (18-24м) | -36м |
| **HOLD** | SQL Server DWH 2008 | Legacy Database | Миграция на Event Store + Data Lake. Поддержка ~12м для Strangler Fig | -12м |
| **HOLD** | PowerBuilder | Legacy UI | Новые сервисы через REST API. Постепенный рефактор UI на React/Vue | -24м |
| **HOLD** | Power BI | Legacy BI Tool | Пилот витрины на Snowflake + Superset. Параллельная поддержка 12м | -12м |

---

## Обоснование по категориям

### Облачная инфраструктура
- **AWS** (Compute, Storage, Networking): Multi-region, соответствие (PCI, HIPAA), управляемые сервисы
- **Избегать**: GCP/Azure (избегаем привязки к поставщику, AWS как базовый выбор)

### Обработка данных
- **Real-time**: Kafka + Kafka Streams / Flink (>100ms SLA)
- **Batch**: Snowflake запросы, dbt трансформации (ежедневно, еженедельно)
- **Избегать**: Spark кластер (сложность ops, высокие затраты)

### Соответствие и безопасность
- **Шифрование**: TLS in-transit, KMS at-rest для медикарт (S3)
- **Аудит**: Event Store (неизменяемые записи), CloudTrail для AWS API
- **RBAC**: Snowflake роли, Kafka ACLs, S3 bucket policies
- **Хранение данных**: 7 лет для финтех-сектора, архив S3 за пределами Vitrine

### Стратегия миграции (Strangler Fig)
1. **0-6м (Пилот)**: Fintech + Clinics домены на Kafka → Snowflake
2. **6-18м (Масштабирование)**: AI Ops, Analytics, Platform → Event Sourcing + DLQ
3. **18-36м (Завершение)**: Camel + DWH → только чтение, затем вывод из эксплуатации
