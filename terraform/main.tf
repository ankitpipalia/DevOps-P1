terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
  cloud {
    organization = "AnkitPipalia"

    workspaces {
      name = "Task-backend"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "a9ecd4c5-920a-4feb-ae4a-c39ea86eb6fc"
  tenant_id       = "9e150f1d-92d8-47f9-bf6f-b44bc4b2fa6c"
  client_id       = "8b616e74-e222-492d-b78a-f50be60faf6c"
  client_secret   = "OtX8Q~hnrWp2FPNiTC3eBJ~A0W7fjS64oKtbncvC"
}

# Local-SSH Key

locals {
  first_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGv53EOrp0C/sRa46Fqkq/E4ZFMnMdFWJis0WlwwyI2vAd/VHemFOb2KcYSVkXg0apMJf2mOwm5W7kFZ9DfnFyJV7s5g/Tc6r1FtbiwmUi18LnKJnbLbQ0WIHuNxYL1DAEQ4dUiEwATzzUYbi1672ZZkn7e4p0g12WFZlQBwSC1bnjbNI/XhUfxNMX8eEuePkenQXA59n1W4fl12zAed5K5MZZt2Z6LreZTkijy8Oc7+GUq6HIeduDD5O9GYFfQNQNIiCGRmTsBcYrwKPCQd/6XzkNwogcpRSIxaP6W+UNVDoJMBKjzYAYBOtyLVHAh7mxj2kIb/AOh3Tdl8JniJzb5lBOl0saxJPMaXBVk1q4l33oJNvnD3pJyf4e6Z1rBeqvZGlR05xe8PPZmRkQoxR2Tcff1qVaUlBdk8HY8JtSnyqrpvfmbVMhEnA17vHiuUDTNM0KJGBXWCk667g7Rslzq89MDCN97So2n0fvH7XkGBjFNbJtMWWkqFJNT6hcKl8= ankit@SF-CPU-082"
}


#Resource-Group

resource "azurerm_resource_group" "back-rg" {
  name     = "Ankit-Backend"
  location = "Central India"

  tags = {
    Task  = "Ankit"
    Ankit = "Resource Group"
  }
}

resource "azurerm_resource_group" "db-rg" {
  name     = "Ankit-Database"
  location = "Central India"

  tags = {
    Task  = "Ankit"
    Ankit = "Resource Group"
  }
}

resource "azurerm_resource_group" "func-rg" {
  name     = "Ankit-Function"
  location = "eastus"

  tags = {
    Task  = "Ankit"
    Ankit = "Resource Group"
  }
}



#Virtual-Network

resource "azurerm_virtual_network" "back_vnet" {
  name                = "Ankit-Backend-Vnet"
  location            = azurerm_resource_group.back-rg.location
  resource_group_name = azurerm_resource_group.back-rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    Task  = "Ankit"
    Ankit = "Virtual Network"
  }
}

resource "azurerm_virtual_network" "db_vnet" {
  name                = "Ankit-mysql-vnet"
  location            = azurerm_resource_group.db-rg.location
  resource_group_name = azurerm_resource_group.db-rg.name
  address_space       = ["10.1.0.0/16"]

  tags = {
    Task  = "Ankit"
    Ankit = "Virtual Network"
  }
}



#Backend Subnet

resource "azurerm_subnet" "back_vnet-vmsssub" {
  name                 = "ankit_vmss_sub"
  resource_group_name  = azurerm_resource_group.back-rg.name
  virtual_network_name = azurerm_virtual_network.back_vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "back_vnet-appgwsub" {
  name                 = "ankit_appgw_sub"
  resource_group_name  = azurerm_resource_group.back-rg.name
  virtual_network_name = azurerm_virtual_network.back_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

#Database Subnet

resource "azurerm_subnet" "db_vnet-vmsub" {
  name                 = "ankit_virtual_machine_sub"
  resource_group_name  = azurerm_resource_group.db-rg.name
  virtual_network_name = azurerm_virtual_network.db_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "db_vnet-mysqlsub" {
  name                 = "mysql"
  resource_group_name  = azurerm_resource_group.db-rg.name
  virtual_network_name = azurerm_virtual_network.db_vnet.name
  address_prefixes     = ["10.1.0.0/24"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

#Database DNS

resource "azurerm_private_dns_zone" "db-pvt-dns" {
  name                = "ankit-db-server.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.db-rg.name

  tags = {
    Task  = "Ankit"
    Ankit = "DNS"
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "db-pvt-dns-vnetlink" {
  name                  = "ankit-db-server.mysql.database.azure.com"
  private_dns_zone_name = azurerm_private_dns_zone.db-pvt-dns.name
  virtual_network_id    = azurerm_virtual_network.db_vnet.id
  resource_group_name   = azurerm_resource_group.db-rg.name

  tags = {
    Task  = "Ankit"
    Ankit = "DNS"
  }
}

#Database

resource "azurerm_mysql_flexible_server" "db-server" {
  name                   = "ankit-db-server"
  resource_group_name    = azurerm_resource_group.db-rg.name
  location               = azurerm_resource_group.db-rg.location
  administrator_login    = "ankit"
  administrator_password = "keVal@14"
  sku_name               = "B_Standard_B1s"
  backup_retention_days  = 7
  delegated_subnet_id    = azurerm_subnet.db_vnet-mysqlsub.id
  private_dns_zone_id    = azurerm_private_dns_zone.db-pvt-dns.id

  depends_on = [azurerm_private_dns_zone_virtual_network_link.db-pvt-dns-vnetlink]

  tags = {
    Task  = "Ankit"
    Ankit = "Database"
  }
}


resource "azurerm_mysql_flexible_database" "azure-mysqldb" {
  name                = "Ankit-MysqlDB"
  resource_group_name = azurerm_resource_group.db-rg.name
  server_name         = azurerm_mysql_flexible_server.db-server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

#Application Gateway

resource "azurerm_public_ip" "appgw-pubip" {
  name                = "appgw-pubip"
  location            = azurerm_resource_group.back-rg.location
  resource_group_name = azurerm_resource_group.back-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Task  = "Ankit"
    Ankit = "Application Gateway"
  }
}

resource "azurerm_application_gateway" "app_gateway" {
  name                = "AppGateway"
  location            = azurerm_resource_group.back-rg.location
  resource_group_name = azurerm_resource_group.back-rg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "AppGwIpConfig"
    subnet_id = azurerm_subnet.back_vnet-appgwsub.id
  }

  frontend_port {
    name = "HttpsFrontendPort"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "AppGwFrontendIp"
    public_ip_address_id = azurerm_public_ip.appgw-pubip.id
  }

  backend_address_pool {
    name = "BackendPool"
  }

  backend_http_settings {
    name                  = "BackendHttpSettings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  probe {
    name                = "HealthProbe"
    host                = "127.0.0.1"
    interval            = 30
    path                = "/"
    protocol            = "Http"
    timeout             = 30
    unhealthy_threshold = 3
  }

  http_listener {
    name                           = "HttpsListener"
    frontend_ip_configuration_name = "AppGwFrontendIp"
    frontend_port_name             = "HttpsFrontendPort"
    protocol                       = "Https"
    ssl_certificate_name           = "ssl-cert"
  }

  request_routing_rule {
    name                       = "RequestRoutingRule"
    rule_type                  = "Basic"
    http_listener_name         = "HttpsListener"
    backend_address_pool_name  = "BackendPool"
    backend_http_settings_name = "BackendHttpSettings"
  }

  ssl_certificate {
    name     = "ssl-cert"
    data     = filebase64("test-cert.pfx")
    password = "test"
  }
}

#Virtual-Machine Scale Set

data "azurerm_shared_image_version" "custom_image" {
  name                = "0.0.3"
  gallery_name        = "ankit_task_image"
  image_name          = "ankittaskimage"
  resource_group_name = "Vm-Image"
}

resource "azurerm_linux_virtual_machine_scale_set" "backend_vmss" {
  name                = "Ankit-VMSS"
  location            = azurerm_resource_group.back-rg.location
  resource_group_name = azurerm_resource_group.back-rg.name
  sku                 = "Standard_B1s"
  instances           = 2
  admin_username      = "ankit"
  secure_boot_enabled = true

  admin_ssh_key {
    username   = "ankit"
    public_key = local.first_public_key
  }

  source_image_id = data.azurerm_shared_image_version.custom_image.id

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "Backend_NetworkProfile"
    primary = true

    ip_configuration {
      name      = "VMSS_IPConfiguration"
      primary   = true
      subnet_id = azurerm_subnet.back_vnet-vmsssub.id

      application_gateway_backend_address_pool_ids = [for pool in azurerm_application_gateway.app_gateway.backend_address_pool : pool.id if pool.name == "BackendPool"]
    }
  }
}

resource "azurerm_monitor_autoscale_setting" "backend_vmss_autoscale" {
  name                = "backend-vmss-autoscale"
  location            = azurerm_resource_group.back-rg.location
  resource_group_name = azurerm_resource_group.back-rg.name

  target_resource_id = azurerm_linux_virtual_machine_scale_set.backend_vmss.id

  profile {
    name = "autoscale-profile"

    capacity {
      default = 5
      minimum = 2
      maximum = 5
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.backend_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 80
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.backend_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 60
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}

#VNet-Peering

resource "azurerm_virtual_network_peering" "db-back-peer" {
  name                         = "db2back"
  resource_group_name          = azurerm_resource_group.db-rg.name
  virtual_network_name         = azurerm_virtual_network.db_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.back_vnet.id
  allow_virtual_network_access = true

  depends_on = [azurerm_virtual_network_peering.back-db-peer]
}

resource "azurerm_virtual_network_peering" "back-db-peer" {
  name                         = "back2db"
  resource_group_name          = azurerm_resource_group.back-rg.name
  virtual_network_name         = azurerm_virtual_network.back_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.db_vnet.id
  allow_virtual_network_access = true
}

# Azure Storage

resource "azurerm_storage_account" "func-stg" {
  name                     = "ankitfunctiontaskstg"
  resource_group_name      = azurerm_resource_group.func-rg.name
  location                 = azurerm_resource_group.func-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  depends_on = [azurerm_resource_group.func-rg]

  tags = {
    Task  = "Ankit"
    Ankit = "Function"
  }
}


# Azure Service Plan For Function

resource "azurerm_service_plan" "func-sp" {
  name                = "ankittaskfunctionsplan"
  resource_group_name = azurerm_resource_group.func-rg.name
  location            = azurerm_resource_group.func-rg.location
  os_type             = "Linux"
  sku_name            = "B1"

  depends_on = [azurerm_storage_account.func-stg]

  tags = {
    Task  = "Ankit"
    Ankit = "Function"
  }
}

# Azure Function 

resource "azurerm_linux_function_app" "function_app" {
  name                = "azure-functions-python-app"
  resource_group_name = azurerm_resource_group.func-rg.name
  location            = azurerm_resource_group.func-rg.location
  service_plan_id     = azurerm_service_plan.func-sp.id
  #service_plan_id           = azurerm_app_service_plan.func-sp.id
  storage_account_name       = azurerm_storage_account.func-stg.name
  storage_account_access_key = azurerm_storage_account.func-stg.primary_access_key
  https_only                 = true

  site_config {
    minimum_tls_version = "1.2"
  }

  depends_on = [azurerm_service_plan.func-sp]

  tags = {
    Task  = "Ankit"
    Ankit = "Function"
  }
}