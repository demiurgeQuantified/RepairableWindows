local TimedActionUtils = require "Starlit/client/timedActions/TimedActionUtils"

local windowWeight = ScriptManager.instance:getItem("RepairableWindows.GlassPane"):getActualWeight()

---@type ItemContainer_Predicate
local predicateNotBroken = function(item)
    return not item:isBroken()
end

---@class RemoveWindowAction : ISBaseTimedAction
---@field character IsoGameCharacter
---@field window IsoWindow
local RemoveWindowAction = ISBaseTimedAction:derive("FWWindowAction")

RemoveWindowAction.isValidStart = function(self)
    local primaryHandItem = self.character:getPrimaryHandItem()
    if not primaryHandItem:hasTag("Crowbar") or primaryHandItem:isBroken() then
        return false
    end
    if not self.character:getInventory():hasRoomFor(self.character, windowWeight) then
        return false
    end
    return true
end

RemoveWindowAction.waitToStart = function(self)
    self.character:faceThisObject(self.window)
    return self.character:shouldBeTurning()
end

RemoveWindowAction.isValid = function(self)
    -- ensure the object hasn't been removed and that the window hasn't been smashed
    return self.window:getSquare() and not self.window:isSmashed()
end

RemoveWindowAction.perform = function(self)
    local square = self.window:getSquare()
    sendClientCommand(
        "RepairableWindows", "removeWindow",
        {x = square:getX(), y = square:getY(), z = square:getZ(),
            i = self.window:getObjectIndex()})

    ISBaseTimedAction.perform(self)
end

RemoveWindowAction.start = function(self)
    self:setActionAnim("RemoveBarricade")
    self:setAnimVariable("RemoveBarricade", "CrowbarMid")
end

---@param character IsoGameCharacter
---@param window IsoWindow
RemoveWindowAction.queueNew = function(character, window)
    local square = AdjacentFreeTileFinder.FindWindowOrDoor(
        window:getSquare(), window, character)
    if not square then return end

    local crowbar = character:getInventory():getFirstTagEvalRecurse(
        "Crowbar", predicateNotBroken)
    if not crowbar then return end

    ISTimedActionQueue.add(ISWalkToTimedAction:new(character, square))
    TimedActionUtils.transferAndEquip(character, crowbar, "primary")
    ISTimedActionQueue.add(
        RemoveWindowAction.new(character, window)
    )
end

---@param character IsoGameCharacter
---@param window IsoWindow
---@return RemoveWindowAction
RemoveWindowAction.new = function(character, window)
    local o = ISBaseTimedAction:new(character) --[[@as RemoveWindowAction]]
    setmetatable(o, RemoveWindowAction)

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

return RemoveWindowAction