# Проектирование целевой архитектуры и оценка рисков

## Описание

Документирует целевую архитектуру Future 2.0 на горизонт 3 года с переходом от монолитного DWH на Event-Driven Data Mesh.

## Структура файлов

- **c4-architecture.md** — Текущее состояние, целевое состояние, 3 фазы трансформации, маппинг компонентов
- **c4-architecture-diagram.md** — Текстовая C4-диаграмма (7 слоев), ASCII-art визуализация
- **risk_matrix.md** — 20 рисков по категориям, матрица приоритетности (P × I)
- **mitigation_plan.md** — План действий для каждого риска, owner, timelines, success metrics

## Основные результаты

### Целевая архитектура (Фаза 3, 36 месяцев)
- Event-Driven Data Mesh с 6 независимыми доменами
- Kafka как центральная платформа обмена событиями
- Snowflake Data Lake для self-service BI (витрина)
- PostgreSQL Event Store (append-only)
- Полная отмена Legacy: DWH (SQL Server), ESB (Camel), PowerBuilder

### Фазовая миграция
- **Фаза 1 (0–6м)**: Пилот fintech + clinics в Kafka, vitrine v1
- **Фаза 2 (6–18м)**: Расширение на 4+ домена, stream analytics, anti-corruption layers
- **Фаза 3 (18–36м)**: Выключение Legacy, 100% event-driven workflows

### Матрица рисков
- **8 высокоприоритетных** (P×I ≥ 9): дублирование событий, skill gaps, resistance to change, latency, data loss, ESB overload, compliance, consistency
- **12 среднеприоритетных** (P×I = 4–6): миграционная надежность, API bottlenecks, observability, schema versioning, DLQ strategy и др.

## Использование

1. Прочитать **c4-architecture.md** для понимания трансформации по фазам
2. Просмотреть **c4-architecture-diagram.md** для визуального понимания слоев и компонентов
3. Изучить **risk_matrix.md** для оценки рисков и их приоритетности
4. Использовать **mitigation_plan.md** для планирования действий и отслеживания прогресса

## Метрики успеха

| Фаза | Time-to-Market | Latency | Uptime | Legacy Usage |
|------|---|---|---|---|
| Текущее | 2–3 мес | часы | 99% | 100% |
| Фаза 1 | 1–2 мес | 5–10 сек | 99.5% | 60% |
| Фаза 2 | 2 нед | <1 сек | 99.9% | 20% |
| Фаза 3 | <1 нед | <1 сек (real-time) | 99.99% | 0% |

## Диаграммы (Mermaid)

Для визуализации архитектуры ФАЗЫ 3:

- **phase3-architecture.mermaid** — Полная архитектура ФАЗЫ 3 (UI, API Gateway, Kafka, 6 доменов, Stream Processing, Data Storage, Observability)
- **phase3-event-flows.mermaid** — Потоки событий между доменами (8+ ключевых событий)
- **phase3-data-mesh.mermaid** — Data Mesh топология с 4 доменными data products (Fintech, Clinics, AI Ops, Platform)

Диаграммы отрисовываются автоматически в GitHub/GitLab (используется Mermaid Live Editor).
