<#  
.NOTES
    THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR 
    FITNESS FOR A PARTICULAR PURPOSE.

    This sample is not supported under any Microsoft standard support program or service. 
    The script is provided AS IS without warranty of any kind. Microsoft further disclaims all
    implied warranties including, without limitation, any implied warranties of merchantability
    or of fitness for a particular purpose. The entire risk arising out of the use or performance
    of the sample and documentation remains with you. In no event shall Microsoft, its authors,
    or anyone else involved in the creation, production, or delivery of the script be liable for 
    any damages whatsoever (including, without limitation, damages for loss of business profits, 
    business interruption, loss of business information, or other pecuniary loss) arising out of 
    the use of or inability to use the sample or documentation, even if Microsoft has been advised 
    of the possibility of such damages, rising out of the use of or inability to use the sample script, 
    even if Microsoft has been advised of the possibility of such damages.
#>

# Connecting to the Azure Portal
try {
    # Prompt the user to connect to Azure
    Connect-AzAccount -ErrorAction Stop

    Write-Host "================================" -ForegroundColor Green
    Write-Host "Connected to Azure successfully!" -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green

    # If the script reaches this point, the user has successfully connected.
    # You can add more logic or commands here based on the successful connection.
}
catch {
    # Handle the error and provide more information to the user
    Write-Host "Failed to connect to Azure. Error details: $($_.Exception.Message)" -ForegroundColor Red
    exit 0
}

$filename = "C:\Users\limagui\Documents\Retirements\AppInsightsKeys\AppInsightsWithKeys.csv"
$TotalAZGraph = 0
$Counter = 1000
$Skip = 0
$AppInsights = @()
$TotalAZGraph = Search-AzGraph -Query "where type =~ 'microsoft.insights/components' | count" -UseTenantScope
$TotalAZGraph = $TotalAZGraph | Select-Object -ExpandProperty Count 
while ($Skip -lt $TotalAZGraph)
{
    Write-Host "Counter:" $Skip "of total:" $TotalAZGraph 
    $AppInsightsTemp = @()

    if ($skip -eq 0)
    {
        $AppInsightsTemp = Search-AzGraph -Query "resources | where type =~ 'microsoft.insights/components'" -first $Counter -UseTenantScope
    }else
    {
        $AppInsightsTemp = Search-AzGraph -Query "resources | where type =~ 'microsoft.insights/components'" -first $Counter -Skip $Skip -UseTenantScope
    }
    if ($AppInsightsTemp)
    {
        $AppInsights += $AppInsightsTemp
    }
    $Skip += 1000
}
$AppInsightsTemp = $null
$AppInsights = $AppInsights | Sort-Object -Property subscriptionId
$CurrentSub = $null
$AppInsightsWithKeys = @()

foreach ($AppInsightsTemp in $AppInsights)
{
    if ($CurrentSub -ne $AppInsightsTemp.subscriptionId)
    {
        Set-AzContext -SubscriptionId $AppInsightsTemp.subscriptionId | out-null
        $CurrentSub = $AppInsightsTemp.subscriptionId
    }

    $Temp = Get-AzApplicationInsightsApiKey -ResourceGroupName $AppInsightsTemp.resourceGroup -Name $AppInsightsTemp.name

    if ($Temp)
    {
        $Temp | Add-Member -name AppInsName -type NoteProperty -Value $AppInsightsTemp.name
        $Temp | Add-Member -name RG -type NoteProperty -Value $AppInsightsTemp.resourceGroup
        $AppInsightsWithKeys += $Temp
    }
}

if ($AppInsightsWithKeys)
{
    $AppInsightsWithKeys | Export-Csv -NoTypeInformation $filename
}
