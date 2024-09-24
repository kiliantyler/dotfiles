#Requires -Version 7.3
<#
.SYNOPSIS
    Sets up a windows machine for chezmoi

.EXAMPLE
    iex "&{$(irm 'https://install.dotfiles.wiki')}"

    Runs the script with the specified input and output files.
#>


if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
    $CommandLine = "-NoExit -File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
    Start-Process -Wait -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
    Exit
  }
}

iex "&{$(irm 'https://get.chezmoi.io/ps1')} -- init --apply {{USERNAME}}"
