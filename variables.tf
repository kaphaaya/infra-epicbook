
variable "project_prefix" {
  description = "Prefix used to name EpicBook resources"
  type        = string
  default     = "epicbook"
}

variable "location" {
  description = "Azure deployment region"
  type        = string
  default     = "westus2"
}

variable "vm_size" {
  description = "Azure Linux VM size"
  type        = string
  default     = "Standard_D2s_v7"
}

variable "admin_username" {
  description = "Linux administrator username"
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  description = "Public SSH key for VM access"
  type        = string
}

variable "db_admin_username" {
  description = "MySQL administrator username"
  type        = string
  default     = "epicbookadmin"
}

variable "db_admin_password" {
  description = "MySQL administrator password"
  type        = string
  sensitive   = true
}

variable "mysql_sku" {
  description = "Azure MySQL Flexible Server SKU"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "mysql_version" {
  description = "MySQL server version"
  type        = string
  default     = "8.0.21"
}

variable "mysql_storage_gb" {
  description = "MySQL storage in GB"
  type        = number
  default     = 20

  validation {
    condition     = var.mysql_storage_gb >= 20
    error_message = "Azure MySQL Flexible Server storage must be at least 20 GB."
  }
}

variable "db_name" {
  description = "EpicBook application database name"
  type        = string
  default     = "epicbook"
}
