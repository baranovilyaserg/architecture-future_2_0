variable "aws_region" {
  description = "AWS регион"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR блок VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR блок подсети"
  type        = string
}

variable "instance_name" {
  description = "Имя экземпляра"
  type        = string
}

variable "instance_type" {
  description = "Тип экземпляра AWS"
  type        = string
}

variable "root_volume_size" {
  description = "Размер корневого диска в ГБ"
  type        = number
}

variable "ebs_volume_size" {
  description = "Размер подключаемого диска в ГБ"
  type        = number
}

variable "ssh_key_name" {
  description = "Имя SSH ключа пары в AWS"
  type        = string
}
