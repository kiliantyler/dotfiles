# PowerShell profile (CurrentUserCurrentHost)
# Location: ~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1

# 1) Initialize mise (tool/version manager)
(& "$HOME\.local\bin\mise.exe" activate pwsh | Out-String) | Invoke-Expression

# If $env:TERM_PROGRAM is vscode skip the rest
if ($env:TERM_PROGRAM -eq 'vscode') {
  return
}

# 2) PSReadLine settings (if available, version-aware)
$psrl = Get-Module -ListAvailable -Name PSReadLine | Sort-Object Version -Descending | Select-Object -First 1
if ($psrl) {
  Import-Module PSReadLine -ErrorAction SilentlyContinue
  if ($psrl.Version.Major -ge 2) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
  }
  Set-PSReadLineOption -EditMode Emacs
  Set-PSReadLineOption -BellStyle None
  Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}

# 3) Bash-like aliases
function which { (Get-Command @args).Source }

# 4) Initialize starship prompt (if available)
if (Get-Command starship -ErrorAction SilentlyContinue) {
  Invoke-Expression (& starship init powershell)
}
