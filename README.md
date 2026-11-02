# B738 Auto Minimums — v1.0 

FlyWithLua script for **X-Plane 11** that initializes the Captain's minimums altitude once after aircraft loading. Default: **200 ft**. Later manual adjustments by the pilot are not overwritten.

## Supported aircraft

- **Zibo 737-800:** sets RADIO mode and the minimums altitude using Zibo-specific datarefs.
- **Laminar Research 737-800 (X-Plane 11):** sets the minimums altitude using `sim/cockpit/misc/radio_altimeter_minimum`. **The script does not attempt to switch RADIO/BARO mode.** During our tests, the original Laminar 737-800 RADIO/BARO outer selector did not respond to mouse operation or the tested Zibo-style commands. The inner knob can still adjust the minimums altitude manually. This is an observation from testing, not a claim about every X-Plane version.
- Other aircraft: no changes.

## Installation

1. Install FlyWithLua for X-Plane 11.
2. Copy `B738_Auto_Minimums.lua` to `X-Plane 11/Resources/plugins/FlyWithLua/Scripts/`.
3. Load the supported aircraft (or use FlyWithLua → Reload all Lua scripts).
4. Verify the PFD minimums display.

## Configuration

Edit the line `local minimums = 200` near the top of the Lua file to choose your preferred altitude in feet. The script waits 3 seconds before setting the altitude and writes **only once per script load**. Reloading all Lua scripts intentionally re-applies the configured value.

## Diagnostic log

`X-Plane 11/Resources/plugins/FlyWithLua/B738_Auto_Minimums_Debug.txt`

Set `local debug_enabled = false` to stop writing the diagnostic file.

## Release validation

This package is a **release candidate**, not yet the final tested Gold Standard. Verify both supported aircraft in X-Plane 11, including manual adjustments after startup, and check that the script is not moved to `Scripts (Quarantine)`.

Aircraft detection uses the ICAO code `B738` and recognizable aircraft folder names (`B737-800X`/`Zibo` or `Laminar Research/Boeing B737-800`). Renamed aircraft folders may need the detection rules adjusted.
