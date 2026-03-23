# Aggregates — Ключевые агрегаты доменов

## Что такое Aggregate?

Aggregate — это кластер объектов, которые работают вместе как одна единица. Каждый aggregate имеет:
- **Root** — объект, через который происходит весь доступ
- **Boundary** — граница, инварианты которой должны сохраняться
- **Invariant** — правило, которое никогда не должно нарушаться
- **ID** — уникальный идентификатор

---

## Fintech Domain Aggregates

### 1. Payment Aggregate

**Root:** `Payment`

**Entities:**
- `Payment` — основной объект платежа
- `PaymentLine` — строка платежа (может быть несколько)

**Value Objects:**
- `Amount` (валюта + сумма)
- `PaymentStatus` (PENDING, COMPLETED, FAILED, REFUNDED)
- `PaymentMethod` (CARD, WIRE, ACH)

**Invariants:**
1. Сумма платежа > 0
2. PaymentStatus может переходить только по определённому пути: PENDING - COMPLETED OR FAILED
3. Refund возможен только для COMPLETED платежей
4. Total amount платежа = сумма всех PaymentLine

**ID:** `payment_id` (UUID)

**Events Published:**
- `PaymentCreated` - PENDING state
- `PaymentSettled` - COMPLETED state
- `PaymentFailed` - FAILED state
- `PaymentRefunded` - REFUNDED state

**Sample Lifecycle:**

1. User creates payment
2. Payment aggregate created with PENDING status
3. Payment processor settles payment
4. PaymentSettled event published
5. Balance aggregate updated

---

### 2. Account Aggregate

**Root:** `Account`

**Entities:**
- `Account` — лицевой счёт
- `Transaction` — отдельная транзакция

**Value Objects:**
- `Balance` (текущий баланс)
- `CreditLimit` (кредитный лимит)
- `AccountStatus` (ACTIVE, SUSPENDED, CLOSED)

**Invariants:**
1. Balance + Pending Credits ≥ 0 (никогда не перейти в долг без кредита)
2. Balance ≤ CreditLimit (не превышать лимит)
3. CreditLimit может измениться только после одобрения кредит-комитета
4. Все транзакции должны быть учтены в Balance

**ID:** `account_id` (UUID)

**Events Published:**
- `AccountCreated`
- `BalanceUpdated`
- `CreditLimitIncreased`
- `CreditLimitDecreased`

**Sample Lifecycle:**

1. Customer creates account with $1000 initial deposit
2. Account aggregate created, Balance = $1000
3. Payment settled, Amount = $100
4. Balance updated to $900
5. BalanceUpdated event published

---

### 3. Credit Aggregate

**Root:** `Credit`

**Entities:**
- `Credit` — кредит
- `PaymentSchedule` — график платежей

**Value Objects:**
- `Amount` (сумма кредита)
- `InterestRate` (ставка)
- `Term` (срок в месяцах)
- `CreditStatus` (PENDING_APPROVAL, APPROVED, ACTIVE, CLOSED, DEFAULTED)

**Invariants:**
1. Сумма кредита > 0
2. InterestRate ≥ 0
3. CreditStatus переходы: PENDING_APPROVAL - APPROVED - ACTIVE - CLOSED or DEFAULTED
4. Все платежи по графику должны быть отслежены
5. После дефолта кредит переходит в DEFAULTED, новые платежи невозможны

**ID:** `credit_id` (UUID)

**Events Published:**
- `CreditCreated`
- `CreditApproved`
- `CreditActivated`
- `InterestAccrued`
- `CreditPaymentMade`
- `CreditDefaulted`

**Sample Lifecycle:**

1. Customer applies for $10k credit at 5% for 24 months
2. Credit aggregate created, PENDING_APPROVAL
3. Credit committee approves
4. CreditApproved event - status = APPROVED
5. Customer starts using, status = ACTIVE
6. Monthly: InterestAccrued event
7. Customer makes payment
8. CreditPaymentMade event


---

## Clinics Domain Aggregates

### 1. Patient Aggregate

**Root:** `Patient`

**Entities:**
- `Patient` — пациент
- `Contact` — контактная информация

**Value Objects:**
- `PatientId` (UUID)
- `PersonalInfo` (ФИО, ДР, не мед. данные)
- `ContactInfo` (телефон, email)
- `PatientStatus` (ACTIVE, INACTIVE, ARCHIVED)

**Invariants:**
1. Пациент должен быть ACTIVE для записи на приём
2. Удалить пациента невозможно, только ARCHIVE
3. ФИО и ДР не могут быть пустыми
4. Контактная информация должна содержать хотя бы один способ связи

**ID:** `patient_id` (UUID)

**Events Published:**
- `PatientRegistered`
- `PatientUpdated`
- `PatientDeactivated`
- `PatientArchived`

---

### 2. Visit Aggregate

**Root:** `Visit`

**Entities:**
- `Visit` — визит
- `Appointment` — запись на приём

**Value Objects:**
- `VisitTime` (дата + время)
- `VisitStatus` (SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED)
- `VisitType` (CONSULTATION, PROCEDURE, CHECK_UP)
- `Provider` (ID врача, но не его данные)

**Invariants:**
1. Visit не может быть запланирован на прошедшую дату
2. VisitStatus: SCHEDULED - IN_PROGRESS - COMPLETED or CANCELLED
3. Врач не может иметь пересекающиеся визиты
4. Patient может отменить только SCHEDULED визиты
5. Клиника может отменить любой визит кроме COMPLETED

**ID:** `visit_id` (UUID)

**Events Published:**
- `VisitScheduled`
- `VisitInProgress`
- `VisitCompleted`
- `VisitCancelled`
- `VisitRescheduled`

**Sample Lifecycle:**

1. Patient schedules visit on March 25, 10:00 AM
2. Visit aggregate created, SCHEDULED
3. VisitScheduled event published
4. On March 25, Doctor marks visit IN_PROGRESS
5. After appointment, Doctor marks COMPLETED
6. VisitCompleted event published
7. Analytics consumes event for capacity planning

---

### 3. Capacity Aggregate

**Root:** `Clinic` (или `Department`)

**Entities:**
- `Clinic` — клиника
- `Schedule` — расписание

**Value Objects:**
- `ClinicId` (UUID)
- `WorkingHours` (время работы)
- `AvailableSlots` (свободные слоты по времени)
- `CurrentLoad` (текущая загруженность)

**Invariants:**
1. AvailableSlots ≥ 0
2. CurrentLoad ≤ MaxCapacity
3. Слот не может быть забронирован дважды
4. Слоты должны быть в рамках WorkingHours

**ID:** `clinic_id` (UUID)

**Events Published:**
- `CapacityUpdated`
- `SlotReserved`
- `SlotCancelled`
- `CapacityWarning` (когда load > 80%)

---

## AI Operations Domain Aggregates

### 1. Model Aggregate

**Root:** `Model`

**Entities:**
- `Model` — ИИ-модель
- `ModelVersion` — версия модели

**Value Objects:**
- `ModelId` (UUID)
- `ModelName` (string)
- `Version` (semantic versioning: v1.0.2)
- `ModelStatus` (TRAINING, TRAINED, DEPLOYED, RETIRED)
- `Metrics` (accuracy, precision, recall)

**Invariants:**
1. Model не может быть DEPLOYED с accuracy < 0.8
2. Version должна быть уникальна для каждой Model
3. Нельзя удалить DEPLOYED модель, только RETIRE
4. Accuracy, Precision, Recall ∈ [0, 1]

**ID:** `model_id` (UUID)

**Events Published:**
- `ModelCreated`
- `ModelTrained` (с метриками)
- `ModelDeployed`
- `ModelRetired`
- `ModelQualityDegraded` (если accuracy упала на >5%)

---

### 2. InferenceJob Aggregate

**Root:** `InferenceJob`

**Entities:**
- `InferenceJob` — запрос на инференс
- `Prediction` — предсказание

**Value Objects:**
- `JobId` (UUID)
- `JobStatus` (QUEUED, IN_PROGRESS, COMPLETED, FAILED)
- `Input` (данные для предсказания)
- `Output` (предсказание + confidence)

**Invariants:**
1. JobStatus: QUEUED - IN_PROGRESS - COMPLETED or FAILED
2. Confidence score ∈ [0, 1]
3. Если JobStatus = FAILED, должна быть error message
4. Timeout for job: 30 minutes

**ID:** `job_id` (UUID)

**Events Published:**
- `InferenceJobCreated`
- `InferenceJobCompleted` (с результатом)
- `InferenceJobFailed` (с error)

---

## Analytics Executive Domain Aggregates

### 1. Report Aggregate

**Root:** `Report`

**Entities:**
- `Report` — отчёт
- `ReportPage` — страница отчёта

**Value Objects:**
- `ReportId` (UUID)
- `ReportStatus` (DRAFT, PUBLISHED, ARCHIVED)
- `Schedule` (расписание обновления)
- `Query` (SQL запрос)

**Invariants:**
1. Report не может быть PUBLISHED, если Query не валидна
2. Schedule должна быть в рамках 1 раз в час до 1 раза в день
3. Только автор может редактировать DRAFT
4. PUBLISHED отчёты видны всем с нужным access level

**ID:** `report_id` (UUID)

**Events Published:**
- `ReportCreated`
- `ReportPublished`
- `ReportUpdated`
- `ReportGenerated` (периодически)

---

## Platform Operations Domain Aggregates

### 1. Service Aggregate

**Root:** `MicroService`

**Entities:**
- `Service` — микросервис
- `HealthCheck` — проверка здоровья

**Value Objects:**
- `ServiceId` (UUID)
- `ServiceName` (string)
- `Health` (HEALTHY, DEGRADED, DOWN)
- `ResponseTime` (ms)
- `ErrorRate` (%)

**Invariants:**
1. ResponseTime > 0
2. ErrorRate ∈ [0, 100]
3. Health = DOWN если ErrorRate > 50% или ResponseTime > SLA
4. SLA должна быть установлена перед deployment

**ID:** `service_id` (UUID)

**Events Published:**
- `ServiceHealthChanged`
- `SLABreached`
- `SLARecovered`

---

## Vitrine Data Product Domain Aggregates

### 1. DataProduct Aggregate

**Root:** `DataProduct`

**Entities:**
- `DataProduct` — данные, владением которых является домен
- `Dataset` — набор таблиц
- `Column` — колонка с типом и описанием

**Value Objects:**
- `ProductId` (UUID)
- `ProductName` (string)
- `Owner` (domain name, e.g., "fintech")
- `Quality` (BRONZE, SILVER, GOLD)
- `SLA` (refresh frequency)

**Invariants:**
1. DataProduct должен иметь Owner (один из 6 доменов)
2. Quality не может быть GOLD, если есть missing data
3. Все колонки должны быть задокументированы
4. GUARANTEE: Non-PII only

**ID:** `product_id` (UUID)

**Events Published:**
- `DataProductCreated`
- `DataProductOwnershipTransferred`
- `DataQualityIssueDetected`

---

## Как использовать Aggregates

**1. Транзакции:**
- Изменения внутри Aggregate — одна транзакция
- Изменения между Aggregates — через события (eventual consistency)

**2. Инварианты:**
- Aggregate несёт ответственность за сохранение инвариантов
- Если инвариант нарушается, exception

**3. Events:**
- События публикуются ПОСЛЕ успешного сохранения Aggregate
- События содержат только публичные данные (no secrets)

**4. Querying:**
- Другой Aggregate не запрашивается напрямую
- Использование Events для обновления read models (Vitrine)

---

## Migration Path (Strangler Fig)

**Week 0:** Все aggregates в одном DWH table (плохо!)
**Week 4:** Payment + Account aggregates выделены в PostgreSQL, события публикуются в Kafka
**Week 8:** Clinics aggregates (Patient, Visit, Capacity) присоединены
**Week 16:** AI Operations, Analytics, Platform aggregates добавлены
**Month 9+:** Legacy DWH depreciated, 100% event-based
