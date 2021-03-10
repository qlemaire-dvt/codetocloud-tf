#output "module_info" {
#  description = "id of the public ip address provisoned."
#  value       = module.servers
#}
#
output "root_public_ip" {
  description = "id of the public ip address provisoned."
  value       = module.servers.*.public_from_vm_id
}

