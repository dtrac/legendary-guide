# Install the Az module if it's not already installed
if (-not (Get-Module -ListAvailable -Name Az)) {
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
}

# Import the Az module
Import-Module Az

# Define variables
$resourceGroupName = "dant-resources"
$location = "uksouth"
$storageAccountName = "tfstate$((Get-Random -Maximum 100000).ToString("00000"))"
$containerName = "tfstate"
$keyVaultName = "tfstatekv$((Get-Random -Maximum 10000).ToString("00000"))"
$subscriptionId = $env:ARM_SUBSCRIPTION_ID

# Login to Azure
Connect-AzAccount
Select-AzSubscription -SubscriptionId $subscriptionId

# Create Resource Group
Write-Output "Creating resource group..."
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create Storage Account
Write-Output "Creating storage account..."
$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -Location $location -SkuName Standard_LRS

# Get Storage Account key
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName)[0].Value

# Create Storage Container
Write-Output "Creating storage container..."
$context = $storageAccount.Context
New-AzStorageContainer -Name $containerName -Context $context

# Create Key Vault
Write-Output "Creating Key Vault..."
$keyVault = New-AzKeyVault -ResourceGroupName $resourceGroupName -VaultName $keyVaultName -Location $location

# Store Storage Account key in Key Vault
Write-Output "Storing storage account key in Key Vault..."
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "TerraformStateKey" -SecretValue (ConvertTo-SecureString $storageAccountKey -AsPlainText -Force)

# Assign permissions to the Key Vault (optional, depends on your setup)
# Here we assume the logged-in user needs access to manage the Key Vault
$userObjectId = (Get-AzADUser -UserPrincipalName (Get-AzContext).Account.Id).Id
Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ObjectId $userObjectId -PermissionsToSecrets get,list,set,delete

# Output Terraform backend configuration
Write-Output "Terraform backend configuration:"
Write-Output @"
terraform {
  backend "azurerm" {
    resource_group_name   = "$resourceGroupName"
    storage_account_name  = "$storageAccountName"
    container_name        = "$containerName"
    key                   = "terraform.tfstate"
    subscription_id       = $subscriptionId
  }
}
"@

# Output Key Vault information
Write-Output "Store the following Key Vault name and secret name in your Terraform variables:"
Write-Output "Key Vault Name: $keyVaultName"
Write-Output "Secret Name: TerraformStateKey"
