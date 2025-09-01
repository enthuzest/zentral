# PowerShell script for creating a new SQL user called myapp using application AppSP with secret
# AppSP is part of an Azure AD admin for the Azure SQL server below
[CmdletBinding()]
param(
     [Parameter(mandatory=$true)]
     [string]$clientId,

     [Parameter(mandatory=$true)]
     [string]$clientSecret,

     [Parameter(mandatory=$true)]
     [string]$tenantId,

     [Parameter(mandatory=$true)]
     [string]$sqlServerName,

     [Parameter(mandatory=$true)]
     [string]$databaseName,

     [Parameter(mandatory=$true)]
     [string]$displayName
 )

$DebugPreference = 'Stop'
$ErrorActionPreference = 'Stop'

$uri = "https://login.microsoftonline.com/$tenantId/oauth2/token"

$form = @{
    grant_type    = 'client_credentials'
    client_id     = $clientId
    client_secret = $clientSecret
    resource      = 'https://database.windows.net/'
}

$result = Invoke-RestMethod -Method Get -Uri $uri -Form $form
Invoke-RestMethod -Uri $uri -Method Get -Body $form -verbose
# $guid = [guid]$adObjectId
# $byteGuid = "";

# foreach ($b in $guid.ToByteArray()) {
#     $byteGuid += [System.String]::Format("{0:X2}", $b);
# }

# $sid = "0x" + $byteGuid;

$SQLServerName = $sqlServerName   # Azure SQL logical server name 
$DatabaseName = $databaseName     # Azure SQL database name

Write-Host "Create SQL connection string"
$conn = New-Object System.Data.SqlClient.SQLConnection 
$conn.ConnectionString = "Data Source=$SQLServerName;Initial Catalog=$DatabaseName;Connect Timeout=30"
$conn.AccessToken = $result.access_token

Write-host "Connect to database and execute SQL script"
$conn.Open() 
$ddlstmt = "IF EXISTS (SELECT [name] from [sys].[database_principals] WHERE [name] = '$displayName')
            BEGIN
                DROP USER [$displayName];
            END"
Write-host " "
Write-host "SQL DDL command"
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($ddlstmt, $conn)       

Write-host "results"
$command.ExecuteNonQuery()
$conn.Close()