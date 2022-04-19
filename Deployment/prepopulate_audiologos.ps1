#Requires -Version 6

Param(
    [string] $name,
    [string] $resourceGroup,
    [string] $subscriptionId,
    [string] $storageAccount,
    [string] $showCommands = "false",
    [string] $logfile = $(Join-Path $PSScriptRoot "deploy_log.txt" -Resolve)
 )

# Script based on this doc: https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-cli

# Mock container and blob names are known and fixed
$blobContainerName = "audiologos"
$audiologoBlobName = "audiologo.wav"
$tadaBlobName = "tada.wav"

# ---------------------------
# Create Storage account and explicitly set it to allow public access to the blobs it will contain (access level is only defined at the container level, not blob level)
# Storage names must be between 3 and 24 characters long and use numbers and lower-case letters only
#$storageAccountName = $name.ToLower()
#Write-Host "Creating the Storage Account for customer service Function App and audio logos" -NoNewline -ForegroundColor Green
#if ($showCommands.ToLower() -eq "true") { Write-Host ""; Write-Host "az storage account create -n ""$storageAccountName"" -l ""$location"" -g ""$resourceGroup"" --sku ""Standard_LRS"" " -NoNewline }
#az storage account create `
#  -n "$storageAccountName" `
#  -l "$location" `
#  -g "$resourceGroup" `
#  --allow-blob-public-access true `
#  --sku "Standard_LRS" `
#  2>> "$logFile" | Out-Null
#Write-Host " - Done." -ForegroundColor Green
# ---------------------------

# Get the az login user name
$accInfo = az account show | ConvertFrom-Json

# Uploading to blog storage requires that we assign ""Storage Blob Data Contributor"" role to the currently logged-in az user
Write-Host "Make currently logged-in az user a 'Storage Blob Data Contributor'" -NoNewline -ForegroundColor Green
if ($showCommands.ToLower() -eq "true") { Write-Host ""; Write-Host "az ad signed-in-user show --query objectId -o tsv | az role assignment create --role ""Storage Blob Data Contributor"" --assignee $($accInfo.user.name) --scope ""/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.Storage/storageAccounts/$storageAccount"" " -NoNewline }
az ad signed-in-user show --query objectId -o tsv | az role assignment create `
    --role "Storage Blob Data Contributor" `
    --assignee $($accInfo.user.name) `
    --scope "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.Storage/storageAccounts/$storageAccount" `
    *>> $logFile | Out-Null
Write-Host " - Done." -ForegroundColor Green

# Create the audio logo storage container
# Note: the list of possible --public-access values are: blob, container, off
Write-Host "Create the audio logo storage container" -NoNewline -ForegroundColor Green
if ($showCommands.ToLower() -eq "true") { Write-Host ""; Write-Host "az storage container create --account-name $storageAccount --name $blobContainerName --public-access blob --auth-mode login" -NoNewline }
az storage container create `
    --account-name $storageAccount `
    --name $blobContainerName `
    --public-access blob `
    --auth-mode login `
    3>&1 2>&1 >> $logFile | Out-Null
Write-Host " - Done." -ForegroundColor Green

    #az storage container create \
    #--account-name <account-name> \
    #--name <container-name> \
    #--resource-group <resource-group>
    #--public-access blob \
    #--account-key <account-key> \
    #--auth-mode key

# Upload audiologo.wav to storage container
Write-Host "Upload audiologo.wav to storage container" -NoNewline -ForegroundColor Green
if ($showCommands.ToLower() -eq "true") { Write-Host ""; Write-Host "az storage blob upload --account-name $storageAccount --container-name $blobContainerName --name $audiologoBlobName --file ..\AudioLogos\$audiologoBlobName --auth-mode login" -NoNewline }
az storage blob upload `
    --account-name $storageAccount `
    --container-name $blobContainerName `
    --name $audiologoBlobName `
    --file ..\AudioLogos\$audiologoBlobName `
    --overwrite `
    --auth-mode login `
    3>&1 2>&1 >> $logFile | Out-Null
Write-Host " - Done." -ForegroundColor Green

# Upload tada.wav to blob storage
Write-Host "Upload tada.wav to blob storage" -NoNewline -ForegroundColor Green
if ($showCommands.ToLower() -eq "true") { Write-Host ""; Write-Host "az storage blob upload --account-name $storageAccount --container-name $blobContainerName --name $tadaBlobName --file ..\AudioLogos\$tadaBlobName --auth-mode login" -NoNewline }
az storage blob upload `
    --account-name $storageAccount `
    --container-name $blobContainerName `
    --name $tadaBlobName `
    --file ..\AudioLogos\$tadaBlobName `
    --overwrite `
    --auth-mode login `
    3>&1 2>&1 >> $logFile | Out-Null
Write-Host " - Done." -ForegroundColor Green

# Create return object
$result = [PSCustomObject]@{
audioLogoURL = "https://$storageAccount.blob.core.windows.net/$blobContainerName/$audiologoBlobName"
}

$result