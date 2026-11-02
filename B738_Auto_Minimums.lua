-- B738 Auto Minimums | v1.0 release candidate
-- X-Plane 11 / FlyWithLua 2.7.x
-- Zibo 737-800 and Laminar Research 737-800 only.
-- Sets minimums ONCE after aircraft initialization; never overrides pilot changes later.

-- Change here your preferred minimums height (feet):
local minimums = 200
local startup_delay_seconds = 3
local debug_enabled = false

local VERSION = "1.0-rc1"
local LOG_FILE = "Resources/plugins/FlyWithLua/B738_Auto_Minimums_Debug.txt"
local prefix = "[B738 Auto Minimums] "

local function log(message)
    local line = os.date("%Y-%m-%d %H:%M:%S") .. " | " .. tostring(message)
    if debug_enabled then
        local file = io.open(LOG_FILE, "a")
        if file then file:write(line, "\n"); file:close() end
    end
    if logMsg then logMsg(prefix .. message) end
end

local function normalize_path(value)
    return tostring(value or ""):lower():gsub("\\", "/")
end

local icao = tostring(PLANE_ICAO or ""):upper()
local path = normalize_path(AIRCRAFT_PATH)
local filename = normalize_path(AIRCRAFT_FILENAME)
local aircraft = "OTHER"

-- Distinguish by aircraft folder, not ICAO (both aircraft report B738).
-- The Zibo folder is normally named "B737-800X"; allow "zibo" in the path.
if icao == "B738" then
    if path:find("b737%-800x") or path:find("zibo", 1, true) then
        aircraft = "ZIBO"
    elseif path:find("laminar research", 1, true) and
           (path:find("boeing b737%-800") or path:find("boeing 737%-800")) then
        aircraft = "LAMINAR"
    end
end

log("LOADED version=" .. VERSION .. " aircraft=" .. aircraft ..
    " ICAO=" .. icao .. " path=" .. path .. " file=" .. filename ..
    " target=" .. tostring(minimums) .. " delay=" .. tostring(startup_delay_seconds))

-- Only bind datarefs belonging to the detected aircraft. Binding the Zibo
-- altitude dataref on the Laminar 737 would quarantine this Lua script.
if aircraft == "ZIBO" then
    dataref("bam_zibo_mode", "laminar/B738/EFIS_control/cpt/minimums", "writable")
    dataref("bam_zibo_height", "laminar/B738/pfd/dh_pilot", "writable")
elseif aircraft == "LAMINAR" then
    dataref("bam_laminar_height", "sim/cockpit/misc/radio_altimeter_minimum", "writable")
end

if aircraft ~= "OTHER" then
    dataref("bam_sim_time", "sim/time/total_running_time_sec", "readonly")
end

local started_at = nil
local applied = false

function bam_apply_once()
    if applied or aircraft == "OTHER" then return end
    if started_at == nil then
        started_at = bam_sim_time
        log("WAIT started_at=" .. tostring(started_at))
        return
    end
    if bam_sim_time - started_at < startup_delay_seconds then return end

    if aircraft == "ZIBO" then
        log("ZIBO BEFORE mode=" .. tostring(bam_zibo_mode) ..
            " height=" .. tostring(bam_zibo_height))
        bam_zibo_mode = 0  -- RADIO
        bam_zibo_height = minimums
        log("ZIBO WRITE mode=0 (RADIO), height=" .. tostring(minimums))
    elseif aircraft == "LAMINAR" then
        log("LAMINAR BEFORE height=" .. tostring(bam_laminar_height))
        -- Laminar XP11: tested altitude dataref; do NOT attempt BARO/RADIO selector.
        bam_laminar_height = minimums
        log("LAMINAR WRITE height=" .. tostring(minimums) ..
            " (RADIO/BARO mode left unchanged)")
    end
    applied = true
    log("DONE; pilot changes will not be overwritten")
end

if aircraft ~= "OTHER" then
    do_every_frame("bam_apply_once()")
else
    log("SKIPPED: aircraft not recognized; no minimums datarefs bound or changed")
end
