# Azure Firewall in Hub VNet
resource "azurerm_firewall" "firewall" {
  name                = "AZFirewall"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  ip_configuration {
    name                 = "AzureFirewallSubnet"
    subnet_id            = azurerm_subnet.hub_firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.firewall_pip.id
  }

  # Associate the firewall with the policy
  firewall_policy_id = azurerm_firewall_policy.fwpolicy.id

  
}

# Public IP for Azure Firewall
resource "azurerm_public_ip" "firewall_pip" {
  name                = "myFirewallPublicIP"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Define the Firewall Policy
resource "azurerm_firewall_policy" "fwpolicy" {
  name                = "fwpolicy"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

}

# Define the Firewall Policy Rule Collection Group
resource "azurerm_firewall_policy_rule_collection_group" "fwpolicy-vpn" {
  name               = "fwpolicy-vpn"
  firewall_policy_id = azurerm_firewall_policy.fwpolicy.id
  priority           = 100

  # Network Rule Collection for VPN to Spoke
  network_rule_collection {
    name     = "vpn-vms"
    priority = 101
    action   = "Allow"
    rule {
      name                   = "Allow-VPN-to-Spk"
      protocols              = ["Any"]
      source_addresses       = ["172.16.13.0/24"]
      destination_addresses  = ["10.130.8.0/24", "10.130.16.0/24"]  # Spoke CIDRs
      destination_ports      = ["3389"]
    }
    rule {
      name                   = "Allow-Spk-to-VPN"
      protocols              = ["Any"]
      source_addresses       = ["10.130.8.0/24", "10.130.16.0/24"]
      destination_addresses  = ["172.16.13.0/24"]  # # VPN CIDR
      destination_ports      = ["3389"]
    }
    
  }

  # Network Rule Collection for VM Outbound
  network_rule_collection {
    name     = "VM-Outbound"
    priority = 150
    action   = "Allow"
    
    rule {
      name                   = "VM-Outbound"
      protocols              = ["Any"]
      source_addresses       = ["10.130.8.0/24", "10.130.16.0/24"]
      destination_addresses  = ["0.0.0.0/0"]  # Outbound internet
      destination_ports      = ["*"]
    }
  }
 
}

#LAW to view the firewall logs and check it is working.
resource "azurerm_log_analytics_workspace" "firwalllogsvpn" {
  name                = "firwalllogsvpn"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "firewall-logs" {
    name = "firewalltolaw"
    target_resource_id = azurerm_firewall.firewall.id
    log_analytics_workspace_id = azurerm_log_analytics_workspace.firwalllogsvpn.id

    log_analytics_destination_type = "AzureDiagnostics"

    log {
        category = "AzureFirewallNetworkRule"
        enabled  = true

        retention_policy {
    
            enabled = true
            }
    }
}

