# KeepAwake

A small PowerShell script that prevents a Windows machine from going to sleep or turning off its display.

## The Problem

On organization-issued laptops, power management is usually locked down by Group Policy. The machine is configured to sleep after a few minutes of inactivity, and the sleep timer cannot be changed — the settings are greyed out, and there is no way to adjust them as a standard user.

This gets in the way whenever you need the machine to stay awake on its own, for example:

- Running a long build, test suite, or data job
- Monitoring a dashboard or watching a long meeting/lecture
- Tethering or using the laptop as a secondary machine

**KeepAwake** works around this restriction. Instead of trying to change the (locked) power settings, it tells Windows that the current session is actively in use, so the OS never initiates sleep while the script is running.

## How It Works

The script calls the Windows API function `SetThreadExecutionState` (from `kernel32.dll`) to set the thread's execution state.

```powershell
[Dllimport("kernel32.dll")]
public static extern uint SetThreadExecutionState(uint flags);
```

It then combines three flags:

| Flag | Value | Meaning |
| --- | --- | --- |
| `ES_CONTINUOUS` | `0x80000000` | Keep the new state active until the next call that clears it, instead of applying it only once |
| `ES_SYSTEM_REQUIRED` | `0x00000001` | Tell Windows the system is in use, so it must not enter sleep |
| `ES_DISPLAY_REQUIRED` | `0x00000002` | Tell Windows the display is in use, so it must not turn off |

```powershell
$flags = $ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED -bor $ES_DISPLAY_REQUIRED
[Awake]::SetThreadExecutionState($flags) | Out-Null
```

Because the state is `ES_CONTINUOUS`, Windows keeps the system awake as long as the calling thread exists. The script therefore sits in an infinite loop so the thread (and thus the awake state) never exits:

```powershell
while ($true) {
    Start-Sleep -Seconds 30
}
```

As soon as you press `CTRL+C` (or close the window), the thread terminates, the execution state resets, and the laptop goes back to its normal power policy.

## Usage

Open PowerShell and run:

```powershell
.\KeepAwake.ps1
```

You should see:

```
==================================
       KEEP AWAKE ENABLED
==================================

Sleep prevention is active.
Press CTRL+C to stop.
```

To stop it, press `CTRL+C` or simply close the window.

### If script execution is blocked

If PowerShell refuses to run the script due to the execution policy, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\KeepAwake.ps1
```

## Notes

- The script only prevents sleep while it is running — it makes no permanent changes to your power settings.
- Since it is the *thread* that holds the awake state, do not close the console window or stop the script unless you want the machine to be allowed to sleep again.
- This is intended for situations where power settings are locked down by IT policy. Use it responsibly and in line with your organization's policies.

## Requirements

- Windows
- PowerShell (built in on all supported versions of Windows)
