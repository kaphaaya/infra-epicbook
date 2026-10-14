# Required assignment outputs — must appear in the pipeline run log.

output "app_public_ip" {
  description = "Public IP address of the EpicBook application VM. Use this for browser testing and the Ansible inventory."
  value       = azurerm_public_ip.vm_pip.ip_address
}

output "backend_ansible_host" {
  description = "Hostname the Ansible playbook uses to connect to the VM (same as app_public_ip)."
  value       = azurerm_public_ip.vm_pip.ip_address
}

output "backend_private_ip" {
  description = "Private IP address of the VM NIC (used for internal service-to-service communication)."
  value       = azurerm_network_interface.vm_nic.private_ip_address
}

output "mysql_fqdn" {
  description = "Fully-qualified hostname of the MySQL Flexible Server."
  value       = azurerm_mysql_flexible_server.mysql.fqdn
}

# Supplementary outputs — useful but not required by the assignment rubric.

output "resource_group_name" {
  description = "Name of the Azure resource group."
  value       = azurerm_resource_group.epicbook.name
}

output "vm_admin_username" {
  description = "VM admin username required for the Ansible inventory."
  value       = var.admin_username
}
