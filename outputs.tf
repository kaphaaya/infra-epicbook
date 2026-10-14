output "vm_public_ip" {
  description = "Public IP address of the EpicBook application VM. Use this for Ansible inventory and browser testing."
  value       = azurerm_public_ip.vm_pip.ip_address
}

output "mysql_hostname" {
  description = "Fully-qualified hostname of the MySQL Flexible Server. Use in JAWSDB_URL."
  value       = azurerm_mysql_flexible_server.mysql.fqdn
}

output "jawsdb_url" {
  description = "MySQL connection URL for the EpicBook app. Store the DB password as a secret; this output shows the template."
  value       = "mysql://${var.db_admin_username}:<DB_ADMIN_PASSWORD>@${azurerm_mysql_flexible_server.mysql.fqdn}:3306/${var.db_name}"
  sensitive   = false
}

output "resource_group_name" {
  description = "Name of the Azure resource group."
  value       = azurerm_resource_group.epicbook.name
}

output "vm_admin_username" {
  description = "VM admin username required for Ansible inventory."
  value       = var.admin_username
}
