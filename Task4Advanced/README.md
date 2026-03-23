# Task4Advanced — Domain-Driven Design & Event Storming

## Назначение

Разложить систему Future 2.0 на 6 независимых доменов (bounded contexts) с использованием подхода Domain-Driven Design (DDD). Показать события, которые публикуются между доменами. Обосновать выбор событийного подхода vs текущей архитектуры (DWH + ESB).

## Структура файлов

### 1. bounded-contexts.md
- **6 основных bounded contexts:**
  - Fintech Domain (платежи, кредиты, балансы)
  - Clinics Domain (пациенты, визиты, лечение)
  - AI Operations Domain (модели, инференс, обучение)
  - Analytics Executive Domain (отчёты, KPIs, BI)
  - Platform Operations Domain (SLA, мониторинг, incidents)
  - Vitrine Data Product Domain (самообслуживание BI, витрина)

- **Для каждого домена:**
  - Ubiquitous Language (язык домена)
  - Key Aggregates (главные объекты)
  - Published Events (какие события публикует)
  - Consumed Events (какие события получает)
  - Compliance требования

- **Anti-Corruption Layers (ACL):**
  - Fintech → Vitrine
  - Clinics → Vitrine
  - AI Ops → Analytics

### 2. aggregates.md
- **Что такое Aggregate?** (boundary, invariants, root)
- **Aggregates по доменам:**
  - Payment, Account, Credit (финтех)
  - Patient, Visit, Capacity (клиники)
  - Model, InferenceJob (ИИ)
  - Report, Dashboard (аналитика)
  - Service, SLA (платформа)
  - DataProduct (витрина)

- **Для каждого Aggregate:**
  - Root entity
  - Value objects
  - Invariants (правила, которые никогда не нарушаются)
  - Events that trigger from it
  - Sample lifecycle

### 3. event-storming.mermaid
- **Диаграмма Event Storming:**
  - Actors (пользователи)
  - Commands (действия)
  - Events (что произошло)
  - Aggregates (объекты, которые изменились)
  - Policies (реакции на события)
  - Storage (где хранятся данные)

### 4. events.md
- **Каталог всех ключевых доменных событий:**
  - fintech.payment.created
  - fintech.payment.settled
  - fintech.balance.updated
  - fintech.credit.approved
  - fintech.interest.accrued
  - clinics.patient.registered
  - clinics.visit.scheduled
  - clinics.visit.completed
  - clinics.treatment.prescribed
  - clinics.capacity.updated
  - ai_ops.model.trained
  - ai_ops.model.deployed
  - ai_ops.inference.completed
  - ai_ops.quality.alert
  - analytics.report.generated
  - analytics.alert.triggered
  - platform.service.health_changed
  - platform.sla.breached

- **Для каждого события:**
  - Description
  - Source Domain
  - Subscribing Domains
  - Semantics (бизнес-значение)
  - Minimal Contract (JSON + Avro Schema)
  - Publishing Guarantees

### 5. justification.md
- **Почему Event-Driven лучше, чем DWH + ESB?**
  - Time-to-Market: 2–3 месяца → 3–4 недели (10x)
  - Latency: 5+ сек → <100ms (RPC to async)
  - Scalability: 1k платежей/сек → 1M платежей/сек
  - Availability: 99% → 99.99%
  - Regional expansion
  - Audit trail
  - Cost: $16M → $6.5M per year (60% savings)

- **Сравнительные таблицы DWH vs Event-Driven**
- **Migration strategy (Strangler Fig pattern)**
- **Risk mitigation**

## Ключевые концепции

### Bounded Context
- Логическая граница, внутри которой язык и модель единые
- Разные контексты могут говорить об одном и том же объекте по-разному
  - Финтех: Payment = объект платежа + статус
  - Витрина: Payment = метрика для отчёта (anonymous)

### Aggregate
- Кластер объектов, который работает как одна единица
- Имеет Root entity и invariants
- Все коммуникации идут через Root
- Все инварианты проверяются перед сохранением

### Event
- Иммутабельная запись о том, что произошло
- Publishes когда aggregate меняется
- Может быть много подписчиков (fan-out)
- Версионируется: v1.0, v1.1 (compatible), v2.0 (breaking)

### Anti-Corruption Layer (ACL)
- Адаптер между двумя контекстами
- Переводит язык одного контекста в язык другого
- Защищает от изменений в других контекстах
- Пример: Fintech → Vitrine (финансовые события → аналитические метрики)

## Миграция (Phases)

### Фаза 1 (Месяцы 0–6): Пилот
- Fintech + Clinics выделены в Kafka
- Event Store (PostgreSQL) для обоих
- Vitrine v1 начинает работать
- DWH, ESB всё ещё активны

### Фаза 2 (Месяцы 6–18): Расширение
- AI Ops + Analytics + Platform присоединены
- ACL для ESB/DWH
- Vitrine v2 (40+ метрик)

### Фаза 3 (Месяцы 18–36): Полная миграция
- DWH deprecated
- ESB deprecated
- PowerBuilder deprecated
- 100% Event-Driven

## Compliance & Data Protection

- **PCI-DSS:** Event Sourcing для audit trail финансовых данных
- **HIPAA:** Clinics домен НЕ передаёт медицинские карты (только операционные метрики)
- **GDPR:** RBAC per data product в Vitrine
- **Audit trail:** 7 лет retention в Event Store

## Успешность Decomposition

✓ Каждый домен может разрабатываться независимо  
✓ Разные команды владеют разными доменами  
✓ События — единственный способ общения (слабая связанность)  
✓ Cada домен владеет своими данными  
✓ Anti-corruption layers защищают от изменений в других доменах  
✓ Витрина объединяет данные всех доменов (но только non-PII)  
✓ Новых подписчиков можно добавлять без изменения источников  