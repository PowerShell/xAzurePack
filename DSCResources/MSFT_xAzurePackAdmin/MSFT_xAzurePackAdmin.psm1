function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [parameter(Mandatory = $true)]
        [System.String]
        $Principal,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $AzurePackAdminCredential,

        [parameter(Mandatory = $true)]
        [System.String]
        $SQLServer,

        [System.String]
        $SQLInstance = "MSSQLSERVER",

        [System.Management.Automation.PSCredential]
        $dbUser
    )

    if($SQLInstance -eq "MSSQLSERVER")
    {
        $ConnectionString = "Data Source=$SQLServer;Initial Catalog=Microsoft.MgmtSvc.Store;User ID=$($dbUser.UserName);Password=$($dbUser.GetNetworkCredential().password)"
    }
    else
    {
        $ConnectionString = "Data Source=$SQLServer\$SQLInstance;Initial Catalog=Microsoft.MgmtSvc.Store;User ID=$($dbUser.UserName);Password=$($dbUser.GetNetworkCredential().password)"
    }

    $Ensure = 
        if(Get-MgmtSvcAdminUser -Principal $Principal -ConnectionString $ConnectionString)
        {
            "Present"
        }
        else
        {
            "Absent"
        }

    $returnValue = @{
        Ensure = $Ensure
        Principal = $Principal
        SQLServer = $SQLServer
        SQLInstance = $SQLInstance
    }

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [parameter(Mandatory = $true)]
        [System.String]
        $Principal,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $AzurePackAdminCredential,

        [parameter(Mandatory = $true)]
        [System.String]
        $SQLServer,

        [System.String]
        $SQLInstance = "MSSQLSERVER",

        [System.Management.Automation.PSCredential]
        $dbUser
    )

    if($SQLInstance -eq "MSSQLSERVER")
    {
        $ConnectionString = "Data Source=$SQLServer;Initial Catalog=Microsoft.MgmtSvc.Store;User ID=$($dbUser.UserName);Password=$($dbUser.GetNetworkCredential().password)"
    }
    else
    {
        $ConnectionString = "Data Source=$SQLServer\$SQLInstance;Initial Catalog=Microsoft.MgmtSvc.Store;User ID=$($dbUser.UserName);Password=$($dbUser.GetNetworkCredential().password)"
    }
        switch($Ensure)
        {
            "Present"
            {
                if(!(Get-MgmtSvcAdminUser -Principal $Principal -ConnectionString $ConnectionString))
                {
                    Add-MgmtSvcAdminUser -Principal $Principal -ConnectionString $ConnectionString
                }
            }
            "Absent"
            {
                if(Get-MgmtSvcAdminUser -Principal $Principal -ConnectionString $ConnectionString)
                {
                    Remove-MgmtSvcAdminUser -Principal $Principal -ConnectionString $ConnectionString
                }
            }
        }

    if(!(Test-TargetResource @PSBoundParameters))
    {
        throw "Set-TargetResouce failed"
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [parameter(Mandatory = $true)]
        [System.String]
        $Principal,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $AzurePackAdminCredential,

        [parameter(Mandatory = $true)]
        [System.String]
        $SQLServer,

        [System.String]
        $SQLInstance = "MSSQLSERVER",

        [System.Management.Automation.PSCredential]
        $dbUser
    )

    $result = ((Get-TargetResource @PSBoundParameters).Ensure -eq $Ensure)

    $result
}


Export-ModuleMember -Function *-TargetResource