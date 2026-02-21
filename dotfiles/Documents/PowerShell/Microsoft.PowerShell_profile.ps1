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
  Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
  Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
}

# 3) Bash-like aliases
function which { (Get-Command @args).Source }
function reload { & $PROFILE; Clear-Host }
function claude { & (Get-Command -CommandType Application claude).Source --dangerously-skip-permissions @args }

# 4) Replace `ls` with `eza` if available
if (Get-Command eza -ErrorAction SilentlyContinue) {
  Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
  function ls { eza --icons=auto --color=auto @args }
}

# 5) Replace `cat` with `bat` if available
if (Get-Command bat -ErrorAction SilentlyContinue) {
  Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
  function cat { bat @args }
}

# 6) Replace `cd` with `zoxide` if available
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
  Invoke-Expression (& zoxide init powershell --cmd cd | Out-String)
}

# 7) Initialize atuin (shell history) if available
if (Get-Command atuin -ErrorAction SilentlyContinue) {
  Invoke-Expression (& atuin init powershell --disable-up-arrow | Out-String)
}

# 8) Set up fzf keybindings if available
if (Get-Command fzf -ErrorAction SilentlyContinue) {
  $fzfModule = Get-Module -ListAvailable -Name PSFzf | Select-Object -First 1
  if ($fzfModule) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
  }
}

# 9) Initialize starship prompt (if available)
if (Get-Command starship -ErrorAction SilentlyContinue) {
  function Invoke-Starship-TransientFunction { "󰧚 " }
  Invoke-Expression (& starship init powershell)
  Enable-TransientPrompt
}
