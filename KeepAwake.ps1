Add-Type @"
using System;
using System.Runtime.InteropServices;

public class Awake
{
    [DllImport("kernel32.dll")]
    public static extern uint SetThreadExecutionState(uint flags);
}
"@

$ES_CONTINUOUS      = [uint32]::Parse("2147483648")
$ES_SYSTEM_REQUIRED = [uint32]1
$ES_DISPLAY_REQUIRED = [uint32]2

$flags = $ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED -bor $ES_DISPLAY_REQUIRED

[Awake]::SetThreadExecutionState($flags) | Out-Null

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "       KEEP AWAKE ENABLED" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Sleep prevention is active." -ForegroundColor Green
Write-Host "Press CTRL+C to stop." -ForegroundColor Yellow
Write-Host ""

while ($true) {
    Start-Sleep -Seconds 30
}