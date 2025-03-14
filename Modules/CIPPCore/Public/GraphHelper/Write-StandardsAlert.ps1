function Write-StandardsAlert {
    <#
    .FUNCTIONALITY
    Internal
    #>
    Param(
        $object,
        $tenant = 'None',
        $standardName = 'None',
        $standardId = $null
    )
    $Table = Get-CIPPTable -tablename CippStandardsAlerts
    $JSONobject = $object | ConvertTo-Json -Depth 10 -Compress
    $PartitionKey = (Get-Date -UFormat '%Y%m%d').ToString()
    $TableRow = @{
        'tenant'       = [string]$tenant
        'standardName' = [string]$standardName
        'object'       = [string]$JSONobject
        'standardId'   = [string]$standardId
        'sentAsAlert'  = $false
        'PartitionKey' = [string]$PartitionKey
        'RowKey'       = [string]([guid]::NewGuid()).ToString()
    }
    $Table.Entity = $TableRow
    Add-CIPPAzDataTableEntity @Table | Out-Null
}
