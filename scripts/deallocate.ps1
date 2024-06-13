
$azfw = Get-AzFirewall -Name dantestfw -ResourceGroupName dant-resources
$azfw.Deallocate()
Set-AzFirewall -AzureFirewall $azfw