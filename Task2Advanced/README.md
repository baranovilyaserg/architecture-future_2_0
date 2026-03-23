CI/CD и удалённое состояние Terraform на AWS S3

Описание

Интеграция Terraform с GitLab CI/CD и удалённым хранением состояния в AWS S3. Pipeline автоматизирует:
- Валидацию Terraform кода (terraform validate, terraform fmt)
- Планирование изменений для каждого окружения (dev, stage, prod)
- Применение изменений вручную (с флагом when: manual)
- Блокировку состояния через DynamoDB (избегает race conditions)

Структура

backend-config/
  dev.hcl    - Конфигурация S3 backend для dev
  stage.hcl  - Конфигурация S3 backend для stage
  prod.hcl   - Конфигурация S3 backend для prod

envs/
  dev/
  stage/
  prod/
    main.tf        - Главная конфигурация
    variables.tf   - Переменные
    terraform.tfvars - Значения
    outputs.tf     - Выходы

.gitlab-ci.yml - GitLab CI/CD pipeline

Предварительная подготовка AWS

1. Создание S3 bucket для состояния

aws s3api create-bucket \
  --bucket future2-terraform-state \
  --region us-east-1

2. Включение версионирования

aws s3api put-bucket-versioning \
  --bucket future2-terraform-state \
  --versioning-configuration Status=Enabled

3. Включение шифрования

aws s3api put-bucket-encryption \
  --bucket future2-terraform-state \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

4. Блокировка публичного доступа

aws s3api put-public-access-block \
  --bucket future2-terraform-state \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

5. Создание DynamoDB таблицы для блокировок

aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1

Настройка GitLab CI/CD

1. Добавление переменных окружения в GitLab

Перейти в Settings -> CI/CD -> Variables

Добавить переменные (Protected, не видны в output):

AWS_ACCESS_KEY_ID - AWS ключ доступа
AWS_SECRET_ACCESS_KEY - AWS секретный ключ
AWS_DEFAULT_REGION - us-east-1 (опционально)

IAM политика для AWS ключа (минимальные права)

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketVersioning"
      ],
      "Resource": "arn:aws:s3:::future2-terraform-state"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::future2-terraform-state/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:DescribeTable",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:*:table/terraform-locks"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "vpc:*"
      ],
      "Resource": "*"
    }
  ]
}

Pipeline stages

1. Validate (параллельно для всех окружений)
   - terraform validate
   - terraform fmt -check

2. Plan (параллельно для всех окружений, только на merge requests)
   - terraform plan -out=tfplan
   - Сохранение плана в artifacts

3. Apply (отдельно для каждого окружения, только на main branch, manual trigger)
   - terraform apply -input=false tfplan

Использование

Локальное развёртывание

cd envs/dev
terraform init -backend-config=../../backend-config/dev.hcl
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars

Через GitLab CI/CD

1. Создать merge request в main ветку
2. Pipeline автоматически запустит validate и plan
3. Посмотреть результаты plan в CI/CD -> Pipelines
4. После merge в main, вручную запустить apply (кнопка в UI)

Переопределение переменных

Для локального тестирования:

terraform apply -var-file=terraform.tfvars -var="instance_type=t3.small"

Для изменения в pipeline - отредактировать terraform.tfvars перед коммитом.

Просмотр состояния

terraform show

Вывод outputs:

terraform output

Удаление ресурсов

cd envs/dev
terraform destroy -var-file=terraform.tfvars

Важные замечания

- Состояние НЕ хранится локально (.gitignore содержит *.tfstate)
- S3 bucket должен быть создан до первого запуска pipeline
- DynamoDB таблица требуется для предотвращения race conditions при параллельных apply
- AWS credentials передаются через GitLab CI/CD переменные (не в коде)
- Каждое окружение имеет отдельное состояние (dev/terraform.tfstate, stage/terraform.tfstate, prod/terraform.tfstate)
- apply работает только на main branch и требует ручного подтверждения
- plan доступен на всех merge requests для предварительного просмотра
- terraform fmt -check проверяет форматирование кода (не меняет файлы в CI)

Безопасность

- S3 bucket защищён от публичного доступа (Block Public Access)
- Версионирование включено (возможность восстановления старых состояний)
- Шифрование включено (AES256)
- DynamoDB таблица для блокировок (no race conditions)
- AWS credentials хранятся в защищённых переменных GitLab
- Каждое окружение использует отдельные ключи в S3

Troubleshooting

Ошибка: No credentials provided
AWS_ACCESS_KEY_ID и AWS_SECRET_ACCESS_KEY установлены в GitLab.

Ошибка: terraform init fails with backend error
Проверить S3 bucket существует и DynamoDB таблица создана.

Блокировка состояния

Если состояние заблокировано:

aws dynamodb scan --table-name terraform-locks
aws dynamodb delete-item \
  --table-name terraform-locks \
  --key '{"LockID": {"S": "future2-terraform-state/dev/terraform.tfstate"}}'

Просмотр истории изменений

aws s3api list-object-versions \
  --bucket future2-terraform-state \
  --prefix dev/