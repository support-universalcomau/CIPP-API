function Invoke-CIPPStandardSPEmailAttestation {
    <#
    .FUNCTIONALITY
        Internal
    .COMPONENT
        (APIName) SPEmailAttestation
    .SYNOPSIS
        (Label) Require re-authentication with verification code
    .DESCRIPTION
        (Helptext) Ensure re-authentication with verification code is restricted
        (DocsDescription) Ensure re-authentication with verification code is restricted
    .NOTES
        CAT
            SharePoint Standards
        TAG
            "CIS"
        ADDEDCOMPONENT
            {"type":"number","name":"standards.SPEmailAttestation.Days","label":"Require re-authentication every X Days (Default 15)"}
        IMPACT
            Medium Impact
        ADDEDDATE
            2024-07-09
        POWERSHELLEQUIVALENT
            Set-SPOTenant -EmailAttestationRequired \$true -EmailAttestationReAuthDays 15
        RECOMMENDEDBY
            "CIS"
            "CIPP"
        UPDATECOMMENTBLOCK
            Run the Tools\Update-StandardsComments.ps1 script to update this comment block
    .LINK
        https://docs.cipp.app/user-documentation/tenant/standards/list-standards/sharepoint-standards#medium-impact
    #>

    param($Tenant, $Settings)

    $CurrentState = Get-CIPPSPOTenant -TenantFilter $Tenant |
    Select-Object -Property EmailAttestationReAuthDays, EmailAttestationRequired

    $StateIsCorrect = ($CurrentState.EmailAttestationReAuthDays -eq $Settings.Days) -and
    ($CurrentState.EmailAttestationRequired -eq $true)

    if ($Settings.remediate -eq $true) {
        if ($StateIsCorrect -eq $true) {
            Write-LogMessage -API 'Standards' -Tenant $Tenant -Message 'SharePoint reauthentication with verification code is already restricted.' -Sev Info
        } else {
            $Properties = @{
                EmailAttestationReAuthDays = $Settings.Days
                EmailAttestationRequired   = $true
            }

            try {
                Get-CIPPSPOTenant -TenantFilter $Tenant | Set-CIPPSPOTenant -Properties $Properties
                Write-LogMessage -API 'Standards' -Tenant $Tenant -Message 'Successfully set reauthentication with verification code restriction.' -Sev Info
            } catch {
                $ErrorMessage = Get-NormalizedError -Message $_.Exception.Message
                Write-LogMessage -API 'Standards' -Tenant $Tenant -Message "Failed to set reauthentication with verification code restriction. Error: $ErrorMessage" -Sev Error
            }
        }
    }

    if ($Settings.alert -eq $true) {
        if ($StateIsCorrect -eq $true) {
            Write-LogMessage -API 'Standards' -Tenant $Tenant -Message 'Reauthentication with verification code is restricted.' -Sev Info
        } else {
            Write-LogMessage -API 'Standards' -Tenant $Tenant -Message 'Reauthentication with verification code is not restricted.' -Sev Alert
        }
    }

    if ($Settings.report -eq $true) {
        Add-CIPPBPAField -FieldName 'SPEmailAttestation' -FieldValue $StateIsCorrect -StoreAs bool -Tenant $Tenant
        if ($StateIsCorrect) {
            $FieldValue = $true
        } else {
            $FieldValue = $CurrentState
        }
        Set-CIPPStandardsCompareField -FieldName 'standards.SPEmailAttestation' -FieldValue $FieldValue -TenantFilter $Tenant
    }
}
