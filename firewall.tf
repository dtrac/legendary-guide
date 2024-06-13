
# Define Azure Firewall
resource "azurerm_firewall" "example" {
  name                = "example-firewall"
  sku_tier            = "Premium"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = "AZFW_VNet"
}

# Define Firewall Policy
resource "azurerm_firewall_policy" "example" {
  name                = "example-firewall-policy"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Define network rules
  network_rule {
    name                  = "AllowKMS"
    source_addresses      = ["*"]
    destination_addresses = ["AzureCloud"]
    protocols             = ["TCP"]
    destination_ports     = ["1688"]
  }

  network_rule {
    name                  = "AllowNTP"
    source_addresses      = ["*"]
    destination_addresses = ["*"]
    protocols             = ["UDP"]
    destination_ports     = ["123"]
  }

  network_rule {
    name                  = "AllowAzureMonitor"
    source_addresses      = ["*"]
    destination_addresses = ["AzureMonitor"]
    protocols             = ["*"]
    destination_ports     = ["*"]
  }

  network_rule {
    name                  = "AllowAADOutbound"
    source_addresses      = ["*"]
    destination_addresses = ["AzureActiveDirectory"]
    protocols             = ["*"]
    destination_ports     = ["*"]
  }

  # Define application rules
  application_rule {
    name                = "WindowsUpdate"
    protocols           = ["http", "https"]
    fqdn_tags           = ["WindowsUpdate"]
    target_fqdns        = ["*.windowsupdate.com"]
    action              = "Allow"
    priority            = 100
  }

  application_rule {
    name                = "WindowsDiagnostics"
    protocols           = ["http", "https"]
    fqdn_tags           = ["WindowsDiagnostics"]
    target_fqdns        = ["*.microsoft.com"]
    action              = "Allow"
    priority            = 200
  }
}

# Associate Firewall Policy with Firewall
resource "azurerm_firewall_policy_rule_collection_group_association" "example" {
  name                       = "example-association"
  firewall_name              = azurerm_firewall.example.name
  resource_group_name        = azurerm_resource_group.example.name
  firewall_policy_id         = azurerm_firewall_policy.example.id
  priority                   = 100
  provisioning_state         = "Succeeded"
  rule_collection_group_name = "DefaultFirewallPolicy"
}

# Output
output "firewall_public_ip" {
  value = azurerm_firewall.example.ip_configuration[0].public_ip_address
}
