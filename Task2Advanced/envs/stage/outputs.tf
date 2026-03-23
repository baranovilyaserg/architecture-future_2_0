output "instance_id" {
  description = "ID экземпляра EC2"
  value       = module.vm_stage.instance_id
}

output "instance_public_ip" {
  description = "Публичный IP экземпляра"
  value       = module.vm_stage.instance_public_ip
}

output "instance_private_ip" {
  description = "Приватный IP экземпляра"
  value       = module.vm_stage.instance_private_ip
}

output "data_volume_id" {
  description = "ID подключаемого диска"
  value       = module.vm_stage.data_volume_id
}
