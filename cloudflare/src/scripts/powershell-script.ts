/**
 * Generates a PowerShell script for Windows using proper Git URLs
 * @param repoUrl Full Git repository URL (e.g., https://github.com/username/repo.git)
 * @param branch Repository branch to use
 * @returns Complete PowerShell installation script
 */
export function generatePowershellScript(repoUrl: string, branch: string): string {
	return `#Requires -Version 7.3
<#
.SYNOPSIS
    Sets up a windows machine for chezmoi

.EXAMPLE
    iex "&{$(irm 'https://install.dotfiles.wiki/?username=yourusername&provider=github&os=windows')}"

.NOTES
    Supported providers: github, gitlab, bitbucket, or any custom domain
    Supports all Git URL formats
#>

if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
    $CommandLine = "-NoExit -File \`"" + $MyInvocation.MyCommand.Path + "\`" " + $MyInvocation.UnboundArguments
    Start-Process -Wait -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
    Exit
  }
}

# Install chezmoi and initialize with the specified repository and branch
iex "&{$(irm 'https://get.chezmoi.io/ps1')} -- init --apply ${repoUrl} --branch ${branch}"
`;
}
