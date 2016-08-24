function AvoidOverUsingCommentSymbol 
{
    <#
        .SYNOPSIS
            Remove extra comment symbols to make code more readable.
        .DESCRIPTION
            Do not over use the comment symbol (#). It makes PowerShell code more difficult to read and maintain. Instead
            use block comments.
        .EXAMPLE
            AvoidOverUsingCommentSymbol -Token $Token
        .INPUTS
            [System.Management.Automation.Language.Token[]]
        .OUTPUTS
            [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
    #>
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.Token[]]
          $Token
    )

    process
    {
        try
        {
            foreach ($tokenItem in $Token)
            {
                if ([regex]::matches($tokenItem.Text,"#").Count -gt 1)
                {
                    $objectSplat = @{
                        TypeName = "Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord"
                        ArgumentList = "$((Get-Help $MyInvocation.MyCommand.Name).Description.Text)",
                            $tokenItem.Extent,$PSCmdlet.MyInvocation.InvocationName,
                            'Warning',
                            $Null
                    }
                    New-Object @objectSplat
                }
            }
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}

function AvoidUsingEndOfLineSemicolons 
{
    <#
        .SYNOPSIS
            Avoid using semicolons (;) at the end of each line.
        .DESCRIPTION
            Avoid using semicolons (;) at the end of each line, PowerShell will not complain about extra semicolons, but they are unecessary
            and get in the way when code is being edited or copy-pasted.
        .EXAMPLE
            AvoidUsingEndOfLineSemicolons -Token $Token
        .INPUTS
            [System.Management.Automation.Language.Token[]]
        .OUTPUTS
            [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
    #>
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.Token[]]
        $Token
    )

    process 
    {
        try
        {
            foreach ($tokenItem in $Token) 
            {
                if ($tokenItem.Text -match ';$') 
                {
                    $objectSplat = @{
                        TypeName = "Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord"
                        ArgumentList = "$((Get-Help $MyInvocation.MyCommand.Name).Description.Text)",
                            $tokenItem.Extent,$PSCmdlet.MyInvocation.InvocationName,
                            'Warning',
                            $Null
                    }
                    New-Object @objectSplat
                }
            }
        }
        catch 
        {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}

function AvoidUsingPipeOutNull
{
    <#
        .SYNOPSIS
            Avoid using (| Out-Null) for better performance.
        .DESCRIPTION
            Avoid using (| Out-Null) for better performance. 
            Instead prefix the line with ([void]) or modify the function to not output anything. 
        .EXAMPLE
            AvoidUsingPipeOutNull -ScriptBlockAst $ScriptBlockAst
        .INPUTS
            [System.Management.Automation.Language.ScriptBlockAst]
        .OUTPUTS
            [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
    #>
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]
        $ScriptBlockAst
    )

    process 
    {
        try
        {
            [ScriptBlock]$predicate = {
                param ([System.Management.Automation.Language.Ast]$Ast)

                if ($Ast -is [System.Management.Automation.Language.PipelineAst])
                {
                    $true
                }
            }

            [System.Management.Automation.Language.Ast[]]$pipelineAsts = $ScriptBlockAst.FindAll($predicate, $true)

            foreach ($pipelineAst in $pipelineAsts) 
            {
                if ($pipelineAst.Extent.Text -like "*|*Out-Null*") 
                {
                    $objectSplat = @{
                        TypeName = "Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord"
                        ArgumentList = "$((Get-Help $MyInvocation.MyCommand.Name).Description.Text)",
                            $pipelineAst.Extent,
                            $PSCmdlet.MyInvocation.InvocationName,
                            'Warning',
                            $null
                    }
                    New-Object @objectSplat
                }
            }
        }
        catch 
        {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}