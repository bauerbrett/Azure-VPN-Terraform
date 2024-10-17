# VNet 1
resource "azurerm_virtual_network" "vnet1" {
  name                = "hub-prd-easus"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.130.0.0/21"]
}
#Azure Firewall Subnet
resource "azurerm_subnet" "hub_firewall_subnet" {
    name                 = "AzureFirewallSubnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet1.name
    address_prefixes = ["10.130.0.0/24"]
}
#VPN Gateway Subnet
resource "azurerm_subnet" "hub_vpngw_subnet" {
    name                = "GatewaySubnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet1.name
    address_prefixes = ["10.130.1.0/24"]
}
# VNet 2
resource "azurerm_virtual_network" "vnet2" {
  name                = "spk1-prd-eaus"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.130.8.0/21"]
}
#VM Subnet
resource "azurerm_subnet" "spk1_vm_subnet" {
    name                = "spk1-vm-subnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet2.name
    address_prefixes = ["10.130.8.0/24"]
}
# VNet 3
resource "azurerm_virtual_network" "vnet3" {
  name                = "spk2-prd-eaus"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.130.16.0/21"]
}
#VM Subnet
resource "azurerm_subnet" "spk2_vm_subnet" {
    name                = "spk2_vm_subnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet3.name
    address_prefixes = ["10.130.16.0/24"]
}

# Peering from Hub to Spoke 1
resource "azurerm_virtual_network_peering" "hub_to_spoke1" {
  name                       = "hubToSpoke1"
  resource_group_name        = azurerm_resource_group.rg.name
  virtual_network_name       = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id  = azurerm_virtual_network.vnet2.id
  allow_forwarded_traffic    = true
  allow_virtual_network_access = true
  allow_gateway_transit      = true
  use_remote_gateways        = false
}

# Peering from Spoke 1 to Hub
resource "azurerm_virtual_network_peering" "spoke1_to_hub" {
  name                       = "spoke1ToHub"
  resource_group_name        = azurerm_resource_group.rg.name
  virtual_network_name       = azurerm_virtual_network.vnet2.name
  remote_virtual_network_id  = azurerm_virtual_network.vnet1.id
  allow_forwarded_traffic    = true
  allow_virtual_network_access = true
  allow_gateway_transit      = false
  use_remote_gateways        = true
}

# Peering from Hub to Spoke 2
resource "azurerm_virtual_network_peering" "hub_to_spoke2" {
  name                      = "hubToSpoke2"
  resource_group_name        = azurerm_resource_group.rg.name
  virtual_network_name       = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id  = azurerm_virtual_network.vnet3.id
  allow_forwarded_traffic    = true
  allow_virtual_network_access = true
  allow_gateway_transit      = true
  use_remote_gateways        = false
}

# Peering from Spoke 2 to Hub
resource "azurerm_virtual_network_peering" "spoke2_to_hub" {
  name                      = "spoke2ToHub"
  resource_group_name        = azurerm_resource_group.rg.name
  virtual_network_name       = azurerm_virtual_network.vnet3.name
  remote_virtual_network_id  = azurerm_virtual_network.vnet1.id
  allow_forwarded_traffic    = true
  allow_virtual_network_access = true
  allow_gateway_transit      = false
  use_remote_gateways        = true

}

# Public IP for VPN Gateway
resource "azurerm_public_ip" "vpn_gateway_pip" {
  name                = "myVpnGatewayPublicIP"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic" # VPN Gateways use dynamic allocation
}
# Public IP for VPN Gateway
resource "azurerm_public_ip" "vpn_gateway_pip2" {
  name                = "myVpnGatewayPublicIP2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic" # VPN Gateways use dynamic allocation
}

# VPN Gateway
resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  name                = "myVpnGateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"  # For P2S VPN

  sku = "VpnGw1"  # Adjust size if needed
  
  active_active = true
  enable_bgp    = false
  
  vpn_client_configuration {
    address_space = ["172.16.13.0/24"]
    aad_tenant = "https://login.microsoftonline.com/134888ca-e6f2-4fb6-9b49-3042d590ea87"
    aad_audience = "41b23e61-6c1e-4545-b367-cd054e0ed4b4"
    aad_issuer    = "https://sts.windows.net/134888ca-e6f2-4fb6-9b49-3042d590ea87/"
    vpn_client_protocols = ["OpenVPN"]
    vpn_auth_types = ["AAD"]
    
  }

  ip_configuration {
    name                          = "vpngateway-ipconfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway_pip.id
    subnet_id                     = azurerm_subnet.hub_vpngw_subnet.id
  }
  ip_configuration {
    name                          = "vpngateway-ipconfig2"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway_pip2.id
    subnet_id                     = azurerm_subnet.hub_vpngw_subnet.id
  }

}

#Route table for the hub
resource "azurerm_route_table" "hubroutes" {
  name                = "hubroutes"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  route {
    name           = "hub2spk1"
    address_prefix = "10.130.8.0/24"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
  }
  route {
    name           = "hub2spk2"
    address_prefix = "10.130.16.0/24"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
  }
  route {
    name           = "gwtovpn"
    address_prefix = "172.16.13.0/24"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
  }

  tags = {
    environment = "Dev"
  }
}
# Route Table Association with the VPN Gateway Subnet
resource "azurerm_subnet_route_table_association" "vpn_gateway_route_association" {
  subnet_id      = azurerm_subnet.hub_vpngw_subnet.id
  route_table_id = azurerm_route_table.hubroutes.id
}

    
#NSG for pk1 sub
resource "azurerm_network_security_group" "spk1_nsg" {
    name = "spk1_nsg"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    
}

#NSG for spk2 sub
resource "azurerm_network_security_group" "spk2_nsg" {
    name = "spk2_nsg"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

}

#Associate with VM subnet on spk1
resource "azurerm_subnet_network_security_group_association" "spoke1_nsg_assoc" {
  subnet_id                 = azurerm_subnet.spk1_vm_subnet.id
  network_security_group_id = azurerm_network_security_group.spk1_nsg.id
}
#Associate with VM subnet on spk2
resource "azurerm_subnet_network_security_group_association" "spoke2_nsg_assoc" {
  subnet_id                 = azurerm_subnet.spk2_vm_subnet.id
  network_security_group_id = azurerm_network_security_group.spk2_nsg.id
}

#Route table for VMs to direct all traffic to Azure Firewall on outbound
#Route table for the hub
resource "azurerm_route_table" "spkroutes" {
  name                = "spkroutes"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  route {
    name           = "spk2internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
  }
  #Need two routes for the VPN client pool. For some reason when using the default/24 it was not specific enough and it used the 
  #default system route instead of the UDR. Because of this I made them more specific and split them into two address ranges.
  route {
    name           = "spktovpn1"
    address_prefix = "172.16.13.0/25"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
  }
  route {
    name           = "spktovpn2"
    address_prefix = "172.16.13.128/25"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
  }

  tags = {
    environment = "Dev"
  }
}
#Associate route table with both spks vm subnets
resource "azurerm_subnet_route_table_association" "spk1_vm_route_association" {
  subnet_id      = azurerm_subnet.spk1_vm_subnet.id
  route_table_id = azurerm_route_table.spkroutes.id
}
resource "azurerm_subnet_route_table_association" "spk2_vm_route_association" {
  subnet_id      = azurerm_subnet.spk2_vm_subnet.id
  route_table_id = azurerm_route_table.spkroutes.id
}

