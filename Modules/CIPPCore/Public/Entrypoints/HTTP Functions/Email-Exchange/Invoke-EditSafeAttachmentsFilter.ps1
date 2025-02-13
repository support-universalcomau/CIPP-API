function Invoke-EditSafeAttachmentsFilter {
    <#
    .FUNCTIONALITY
        Entrypoint
    .ROLE
        Exchange.SpamFilter.Read
    #>
    [CmdletBinding()]
    param($Request, $TriggerMetadata)

    $APIName = $Request.Params.CIPPEndpoint
    Write-LogMessage -headers $Request.Headers -API $APINAME -message 'Accessed this API' -Sev 'Debug'

    # Write to the Azure Functions log stream.
    Write-Host 'PowerShell HTTP trigger function processed a request.'

    # Interact with query parameters or the body of the request.
    $TenantFilter = $Request.Query.TenantFilter

    try {
        $ExoRequestParam = @{
            tenantid = $TenantFilter
            cmdParams = @{
                Identity = $Request.query.RuleName
            }
            useSystemmailbox = $true
        }

        switch ($Request.query.State) {
            'Enable' {
                $ExoRequestParam.Add('cmdlet', 'Enable-SafeAttachmentRule')
            }
            'Disable' {
                $ExoRequestParam.Add('cmdlet', 'Disable-SafeAttachmentRule')
            }
            Default {
                throw 'Invalid state'
            }
        }
        New-ExoRequest @ExoRequestParam

        $Result = "Sucessfully set SafeAttachment rule $($Request.query.RuleName) to $($Request.query.State)"
        Write-LogMessage -headers $Request.Headers -API $APINAME -tenant $TenantFilter -message $Result -Sev Info
    } catch {
        $ErrorMessage = Get-NormalizedError -Message $_.Exception.Message
        $Result = "Failed setting SafeAttachment rule $($Request.query.RuleName) to $($request.query.State). Error: $ErrorMessage"
        Write-LogMessage -headers $Request.Headers -API $APINAME -tenant $TenantFilter -message $Result -Sev 'Error'
    }

    # Associate values to output bindings by calling 'Push-OutputBinding'.
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::OK
            Body       = @{Results = $Result }
    })
}
