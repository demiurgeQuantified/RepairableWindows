local TimedActionUtils = require "Starlit/client/timedActions/TimedActionUtils"

---@class AddWindowAction : ISBaseTimedAction
---@field character IsoGameCharacter
---@field window IsoWindow
local AddWindowAction = ISBaseTimedAction:derive("FWAddWindowAction")

AddWindowAction.isValidStart = function(self)
    if not self.character:getInventory():containsType("RepairableWindows.GlassPane") then
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

AddWindowAction.perform = function(self)
    local square = self.window:getSquare()
    sendClientCommand(
        "RepairableWindows", "addWindow",
        {x = square:getX(), y = square:getY(), z = square:getZ(),
            i = self.window:getObjectIndex(),
            item = self.character:getInventory():getFirstType("RepairableWindows.GlassPane")})

    ISBaseTimedAction.perform(self)
end

---@param character IsoGameCharacter
---@param window IsoWindow
AddWindowAction.queueNew = function(character, window)
    local square = AdjacentFreeTileFinder.FindWindowOrDoor(
        window:getSquare(), window, character)
    if not square then return end

    if not character:getInventory():containsTypeRecurse("RepairableWindows.GlassPane") then return end

    ISTimedActionQueue.add(ISWalkToTimedAction:new(character, square))
    TimedActionUtils.transferFirstType(character, "RepairableWindows.GlassPane")
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