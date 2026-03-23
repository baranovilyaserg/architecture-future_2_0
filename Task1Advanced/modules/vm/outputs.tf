output "instance_id" {
  description = "ID экземпляра EC2"
  value       = aws_instance.vm.id
}

output "instance_private_ip" {
  description = "Приватный IP-адрес экземпляра"
  value       = aws_instance.vm.private_ip
}

output "instance_public_ip" {
  description = "Публичный IP-адрес экземпляра (если назначен)"
  value       = aws_instance.vm.public_ip
}

output "instance_public_dns" {
  description = "Публичное DNS имя экземпляра"
  value       = aws_instance.vm.public_dns
}

output "instance_name" {
  description = "Имя экземпляра"
  value       = var.instance_name
}

output "root_volume_id" {
  description = "ID корневого диска (EBS)"
  value       = aws_instance.vm.root_block_device[0].volume_id
}

output "data_volume_id" {
  description = "ID подключаемого диска (EBS)"
  value       = aws_ebs_volume.data_volume.id
}

output "data_volume_size" {
  description = "Размер подключаемого диска в ГБ"
  value       = aws_ebs_volume.data_volume.size
}

output "security_group_id" {
  description = "ID группы безопасности"
  value       = aws_security_group.vm_sg.id
}

output "security_group_name" {
  description = "Имя группы безопасности"
  value       = aws_security_group.vm_sg.name
}

output "availability_zone" {
  description = "Зона доступности экземпляра"
  value       = aws_instance.vm.availability_zone
}
