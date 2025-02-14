-- Hammerspoon script to automatically update your slack status when in zoom
--
-- To use:
--
-- * Install and set up the slack_status.sh script (make sure it's in your
--   path)
-- * Ensure there is a 'zoom' preset (one is created by default during setup)
-- * Install hammerspoon (brew install hammerspoon) if you don't have it
--   already.
-- * Copy this file to ~/.hammerspoon
-- * Add the following line to ~/.hammerspoon/init.lua
--      local zoom_detect = require("zoom_detect")
-- * If it's a fresh `brew install` of Hammerspoon, start it and make sure
--   accessibility is enabled

-- Configuration
check_interval=30 -- How often to check if you're in zoom, in seconds

function update_status(status)
    task = hs.execute("slack_status.sh " .. status, true)
end

function update_presence(presence)
    task = hs.execute("awayback.sh " .. presence, true)
end

function update_dnd(on_or_off)
    task = hs.execute("dnd.sh " .. on_or_off, true)
end

function in_zoom_meeting()
    local a = hs.application.find("zoom.us")
    if a ~= nil then
        m = a:findMenuItem("Join Meeting...")
        -- Start meeting menu item exists and is disabled
        return m ~= nil and not m["enabled"]
    else
        -- Zoom isn't running
        return false
    end
end

inzoom = false
zoomTimer = hs.timer.doEvery(check_interval, function()
    if in_zoom_meeting() then
        if inzoom == false then
            inzoom = true
            hs.notify.show("Started zoom meeting", "Updating slack status", "")
            update_status("zoom")
            update_presence("away")
            update_dnd("on")
        end
    else
        if inzoom == true then
            inzoom = false
            hs.notify.show("Left zoom meeting", "Updating slack status", "")
            update_status("none")
            update_presence("back")
            update_dnd("off")
        end
    end
end)
zoomTimer:start()
