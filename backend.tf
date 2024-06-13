terraform {
  backend "azurerm" {
    resource_group_name   = "dant-resources"
    storage_account_name  = "tfstate70558"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
    subscription_id       = var.subscription_id
  }
}