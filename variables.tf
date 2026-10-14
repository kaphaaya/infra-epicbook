variable "location" {
  description = "Azure region where all resources will be created."
  type        = string
  default     = "uksouth"
}

variable "project_prefix" {
  description = "Short prefix applied to every resource name. Change this if the MySQL server name conflicts globally."
  type        = string
  default     = "epicbook"
}

variable "vm_size" {
  description = "Azure VM SKU for the application server."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  description = "OS-level admin username for the Linux VM. Used by Ansible to connect."
  type        = string
  default     = "ubuntu"
}

variable "admin_ssh_public_key" {
  description = "RSA public key (contents, not path) for SSH access to the VM. Store as a secret pipeline variable."
  type        = string
  sensitive   = true
}

variable "mysql_sku" {
  description = "Azure MySQL Flexible Server SKU. Burstable B_Standard_B1ms is the cheapest tier."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "mysql_version" {
  description = "MySQL engine version."
  type        = string
  default     = "8.0.21"
}

variable "mysql_storage_gb" {
  description = "Allocated storage for the MySQL Flexible Server in GB."
  type        = number
  default     = 20
}

variable "db_admin_username" {
  description = "MySQL Flexible Server administrator login. Azure does not permit 'root', 'admin', or 'azure_superuser'."
  type        = string
  default     = "epicbookadmin"
}

variable "db_admin_password" {
  description = "MySQL Flexible Server administrator password. Store as a secret pipeline variable."
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Name of the application database to create inside MySQL."
  type        = string
  default     = "bookstore"
}
