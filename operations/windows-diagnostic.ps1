# Read-only Windows evidence collection for an approved SSM document.
[CmdletBinding()]
param(
  [ValidateSet('W3SVC','WAS')]
  [string]$ServiceName = 'W3SVC',
  [int]$Minutes = 15
)

$ErrorActionPreference = 'Continue'
Write-Output '== service =='
Get-Service -Name $ServiceName -ErrorAction SilentlyContinue |
  Select-Object Name, Status, StartType

Write-Output '== volumes =='
Get-Volume | Select-Object DriveLetter, SizeRemaining, Size

Write-Output '== recent Application events =='
$start = (Get-Date).AddMinutes(-1 * $Minutes)
Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$start} -MaxEvents 20 |
  Select-Object TimeCreated, Id, LevelDisplayName, ProviderName, Message

if (Get-Module -ListAvailable -Name WebAdministration) {
  Import-Module WebAdministration
  Write-Output '== IIS application pools =='
  Get-ChildItem IIS:\AppPools | Select-Object Name, State
}
