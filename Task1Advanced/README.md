Модульная инфраструктура Terraform для AWS

Описание

Переиспользуемый модуль vm_module для развёртывания ВМ на AWS с поддержкой нескольких сред (dev, stage, prod). Модуль создаёт:
- Экземпляр EC2 с параметризуемыми ядрами и RAM
- Корневой диск (EBS)
- Подключаемый диск (EBS)
- Группу безопасности
- VPC и подсеть для каждого окружения

Структура

modules/vm/
  main.tf       - Ресурсы модуля (EC2, EBS, Security Group)
  variables.tf  - Входные параметры
  outputs.tf    - Выходы модуля (ID, IP, DNS и т.д.)

envs/dev/
envs/stage/
envs/prod/
  main.tf           - Главная конфигурация (VPC, подсеть, использование модуля)
  variables.tf      - Переменные окружения
  terraform.tfvars  - Значения для конкретного окружения

Параметры модуля

instance_name      - Имя экземпляра (string, обязательно)
instance_type      - Тип экземпляра AWS (string, обязательно)
                     Примеры: t3.micro, t3.small, t3.medium, m5.large
root_volume_size   - Размер корневого диска в ГБ (number, обязательно)
                     Диапазон: 20-1000
ebs_volume_size    - Размер подключаемого диска в ГБ (number, обязательно)
                     Диапазон: 10-1000
subnet_id          - ID подсети (string, обязательно)
ssh_key_name       - Имя SSH ключа в AWS (string, обязательно)
ami_id             - ID образа AMI (string, опционально)
                     По умолчанию используется Amazon Linux 2
environment        - Окружение: dev, stage или prod (string, обязательно)
tags               - Дополнительные теги (map(string), опционально)

Выходы модуля

instance_id        - ID экземпляра EC2
instance_private_ip - Приватный IP
instance_public_ip - Публичный IP
instance_public_dns - Публичное DNS имя
root_volume_id     - ID корневого диска
data_volume_id     - ID подключаемого диска
data_volume_size   - Размер подключаемого диска в ГБ
security_group_id  - ID группы безопасности
availability_zone  - Зона доступности

Конфигурация окружений

DEV
Размер: t3.micro (1 ядро, 1 ГБ RAM)
Корневой диск: 20 ГБ
Подключаемый диск: 50 ГБ
VPC CIDR: 10.0.0.0/16
Subnet CIDR: 10.0.1.0/24

STAGE
Размер: t3.small (2 ядра, 2 ГБ RAM)
Корневой диск: 30 ГБ
Подключаемый диск: 100 ГБ
VPC CIDR: 10.1.0.0/16
Subnet CIDR: 10.1.1.0/24

PROD
Размер: t3.medium (2 ядра, 4 ГБ RAM)
Корневой диск: 50 ГБ
Подключаемый диск: 200 ГБ
VPC CIDR: 10.2.0.0/16
Subnet CIDR: 10.2.1.0/24

Использование

Подготовка

1. Terraform версии 1.0 или выше
2. AWS credentials (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
3. SSH ключ с именем из terraform.tfvars существует в AWS

Развёртывание окружения dev

cd envs/dev
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars

Развёртывание окружения stage

cd envs/stage
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars

Развёртывание окружения prod

cd envs/prod
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars

Переопределение параметров

Для временного изменения параметра используйте флаг -var:

terraform apply -var-file=terraform.tfvars -var="instance_type=t3.small"

Получение выходов

После развёртывания получите выходные значения:

terraform output

Удаление ресурсов

cd envs/dev (или stage/prod)
terraform destroy

Особенности

- Все диски зашифрованы (EBS encryption enabled)
- Используется IMDSv2 для более высокой безопасности
- Автоматическое создание VPC и подсети для каждого окружения
- Валидация параметров (типы экземпляров, размеры дисков)
- Теги применяются ко всем ресурсам для отслеживания
- Security Group разрешает SSH на порту 22 (0.0.0.0/0)
- Подключаемый диск может быть переподключён к другому экземпляру (skip_destroy = false)
- Детальный мониторинг экземпляра (CloudWatch monitoring enabled)

Примечания

- SSH ключ должен быть предварительно создан в AWS EC2 для выбранного региона
- На продакшене рекомендуется ограничить доступ SSH (вместо 0.0.0.0/0)
- Для более сложных сетевых топологий модифицируйте Security Group
- Используйте AWS CloudWatch для мониторинга
- Для S3 backend используйте Задание 2 (CI/CD)

Поддерживаемые регионы AWS

По умолчанию: us-east-1

Для смены региона отредактируйте terraform.tfvars:

aws_region = "eu-west-1"
