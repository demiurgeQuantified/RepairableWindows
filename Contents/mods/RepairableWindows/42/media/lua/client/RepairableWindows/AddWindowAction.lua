local TimedActionUtils = require "Starlit/client/timedActions/TimedActionUtils"

---@class AddWindowAction : ISBaseTimedAction
---@field character IsoGameCharacter
---@field window IsoWindow
local AddWindowAction = ISBaseTimedAction:derive("FWAddWindowAction")

AddWindowAction.isValidStart = function(self)
    if not self.character:getInventory():containsType("RepairableWindows.LargeGlassPane") then
        return false
    end
    return true
end

AddWindowAction.waitToStart = function(self)
    self.character:faceThisObject(self.window)
    return self.character:shouldBeTurning()
end

AddWindowAction.isValid = function(self)
    -- ensure the object hasn't been removed and that the window hasn't already been replaced
    return self.window:getSquare() and self.window:isSmashed()
end

AddWindowAction.complete = function(self)
    -- TODO: honestly looking at how net timed actions seem to be implemented,
    -- there is literally no way i can rely on them lol
    local inventory = self.character:getInventory()

    self.window:setGlassRemoved(false)
    self.window:setSmashed(false)
    inventory:Remove(
        inventory:getFirstType("RepairableWindows.LargeGlassPane"))

    return true
end

---@param character IsoGameCharacter
---@param window IsoWindow
AddWindowAction.queueNew = function(character, window)
    local square = AdjacentFreeTileFinder.FindWindowOrDoor(
        window:getSquare(), window, character)
    if not square then return end

    if not character:getInventory():containsTypeRecurse("RepairableWindows.LargeGlassPane") then return end

    ISTimedActionQueue.add(ISWalkToTimedAction:new(character, square))
    TimedActionUtils.transferFirstType(character, "RepairableWindows.LargeGlassPane")
    ISTimedActionQueue.add(
        AddWindowAction.new(character, window)
    )
end

---@param character IsoGameCharacter
---@param window IsoWindow
---@return AddWindowAction
AddWindowAction.new = function(character, window)
    local o = ISBaseTimedAction:new(character) --[[@as AddWindowAction]]
    setmetatable(o, AddWindowAction)

    o.window = window

    o.maxTime = 192

    if character:isTimedActionInstant() then
        o.maxTime = 1
    end

    o.stopOnAim = true
    o.stopOnRun = true
    o.stopOnWalk = true

    return o
end

return AddWindowAction