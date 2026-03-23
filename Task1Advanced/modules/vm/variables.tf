variable "instance_name" {
  description = "Имя экземпляра EC2"
  type        = string
}

variable "instance_type" {
  description = "Тип экземпляра (определяет ядра и RAM)"
  type        = string
  validation {
    condition     = can(regex("^t[34]\\.micro$|^t[34]\\.small$|^t[34]\\.medium$|^m[567]i?\\.large$|^m[567]i?\\.xlarge$", var.instance_type))
    error_message = "Недопустимый тип экземпляра AWS"
  }
}

variable "root_volume_size" {
  description = "Размер корневого диска в ГБ"
  type        = number
  validation {
    condition     = var.root_volume_size >= 20 && var.root_volume_size <= 1000
    error_message = "Размер диска должен быть от 20 до 1000 ГБ"
  }
}

variable "ebs_volume_size" {
  description = "Размер подключаемого диска (EBS) в ГБ"
  type        = number
  validation {
    condition     = var.ebs_volume_size >= 10 && var.ebs_volume_size <= 1000
    error_message = "Размер EBS диска должен быть от 10 до 1000 ГБ"
  }
}

variable "subnet_id" {
  description = "ID подсети для размещения экземпляра"
  type        = string
}

variable "ssh_key_name" {
  description = "Имя SSH ключа пары в AWS"
  type        = string
}

variable "ami_id" {
  description = "ID образа AMI для Linux (Amazon Linux 2)"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Окружение (dev, stage, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Окружение должно быть dev, stage или prod"
  }
}

variable "tags" {
  description = "Теги для ресурсов"
  type        = map(string)
  default     = {}
}
