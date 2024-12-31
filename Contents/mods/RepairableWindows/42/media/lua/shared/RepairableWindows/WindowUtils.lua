local Utils = require "Starlit/utils/Utils"

local log = require "RepairableWindows/Log"

local WindowUtils = {}

---@param x integer
---@param y integer
---@param z integer
---@param i integer
---@return IsoWindow?
WindowUtils.getWindow = function(x, y, z, i)
    local window = Utils.getWorldObject(x, y, z, i)
    if not window then
        log("Window at %d,%d,%d,%d does not exist or the square is not loaded.", "debug",
            x, y, z, i)
    end
    return window --[[@as IsoWindow]]
end

---@param x integer
---@param y integer
---@param z integer
---@param i integer
---@param state "glass"|"noGlass"
WindowUtils.setWindowState = function(x, y, z, i, state)
    local window = WindowUtils.getWindow(x, y, z, i)
    if not window then return end

    if state == "glass" then
        window:setGlassRemoved(false)
        window:setSmashed(false)
    elseif state == "noGlass" then
        window:setSmashed(true)
        window:setGlassRemoved(true)
    end
end

---@param character IsoGameCharacter
WindowUtils.getWindowBreakChance = function(character)
    if SandboxVars.RepairableWindows.BreakChance == 1 then
        return 55 - character:getPerkLevel(Perks.Woodwork) * 5
    elseif SandboxVars.RepairableWindows.BreakChance == 2 then
        return 65 - character:getPerkLevel(Perks.Woodwork) * 10
    else
        return 0
    end
end

return WindowUtils