locals {
  common_tags = {
    Project     = "EpicBook"
    ManagedBy   = "Terraform"
    Environment = "production"
  }
}

# ---------------------------------------------------------------------------
# Resource Group
# ---------------------------------------------------------------------------
resource "azurerm_resource_group" "epicbook" {
  name     = "${var.project_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}

# ---------------------------------------------------------------------------
# Networking — VNet, Subnets, NSG
# ---------------------------------------------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_prefix}-vnet"
  location            = azurerm_resource_group.epicbook.location
  resource_group_name = azurerm_resource_group.epicbook.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "vm" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.epicbook.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# NSG — only ports 22 (SSH for Ansible) and 80 (HTTP via Nginx) are open to
# the internet. The Node.js process binds to 8080 internally; Nginx proxies it.
# Tighten the SSH source prefix in production to your CI agent's static IP.
resource "azurerm_network_security_group" "vm_nsg" {
  name                = "${var.project_prefix}-vm-nsg"
  location            = azurerm_resource_group.epicbook.location
  resource_group_name = azurerm_resource_group.epicbook.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "vm_nsg" {
  subnet_id                 = azurerm_subnet.vm.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

# ---------------------------------------------------------------------------
# Public IP and NIC for the VM
# ---------------------------------------------------------------------------
resource "azurerm_public_ip" "vm_pip" {
  name                = "${var.project_prefix}-vm-pip"
  location            = azurerm_resource_group.epicbook.location
  resource_group_name = azurerm_resource_group.epicbook.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.project_prefix}-vm-nic"
  location            = azurerm_resource_group.epicbook.location
  resource_group_name = azurerm_resource_group.epicbook.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip.id
  }

  tags = local.common_tags
}

# ---------------------------------------------------------------------------
# Linux Virtual Machine (Ubuntu 22.04 LTS Gen2, SSH key auth)
# ---------------------------------------------------------------------------
resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "${var.project_prefix}-vm"
  location                        = azurerm_resource_group.epicbook.location
  resource_group_name             = azurerm_resource_group.epicbook.name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [azurerm_network_interface.vm_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = local.common_tags
}

# ---------------------------------------------------------------------------
# Azure Database for MySQL Flexible Server (public access, Burstable tier)
# ---------------------------------------------------------------------------
resource "azurerm_mysql_flexible_server" "mysql" {
  name                = "${var.project_prefix}-mysql-server"
  location            = azurerm_resource_group.epicbook.location
  resource_group_name = azurerm_resource_group.epicbook.name

  administrator_login    = var.db_admin_username
  administrator_password = var.db_admin_password

  sku_name = var.mysql_sku
  version  = var.mysql_version

  storage {
    size_gb           = var.mysql_storage_gb
    auto_grow_enabled = true
  }

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  tags = local.common_tags
}

resource "azurerm_mysql_flexible_database" "bookstore" {
  name                = var.db_name
  resource_group_name = azurerm_resource_group.epicbook.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

# Allow only the application VM's public IP to reach MySQL.
# Terraform resolves the dependency automatically — no circular reference.
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_vm" {
  name                = "allow-epicbook-vm"
  resource_group_name = azurerm_resource_group.epicbook.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  start_ip_address    = azurerm_public_ip.vm_pip.ip_address
  end_ip_address      = azurerm_public_ip.vm_pip.ip_address
}

# Disable SSL enforcement so the Node.js app can connect without
# certificate handling. Re-enable and add SSL params to JAWSDB_URL
# for hardened production deployments.
resource "azurerm_mysql_flexible_server_configuration" "ssl_off" {
  name                = "require_secure_transport"
  resource_group_name = azurerm_resource_group.epicbook.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  value               = "OFF"
}
