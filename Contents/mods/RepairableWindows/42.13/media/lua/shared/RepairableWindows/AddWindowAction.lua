local TimedActionUtils = require("Starlit/timedActions/TimedActionUtils")


---@namespace repairableWindows


---@class AddWindowAction : ISBaseTimedAction
---@field window IsoWindow
local AddWindowAction = ISBaseTimedAction:derive("RepairableWindowsAddWindowAction")


function AddWindowAction:isValidStart()
    if not self.character:getInventory():containsType("RepairableWindows.LargeGlassPane") then
        return false
    end

    return true
end


function AddWindowAction:waitToStart()
    self.character:faceThisObject(self.window)
    return self.character:shouldBeTurning()
end


function AddWindowAction:isValid()
    -- ensure the object hasn't been removed and that the window hasn't already been replaced
    -- TODO: check way more stuff here for security
    return self.window:getSquare() and self.window:isSmashed()
end


function AddWindowAction:complete()
    local inventory = self.character:getInventory()

    self.window:setGlassRemoved(false)
    self.window:setSmashed(false)
    self.window:sync()
    
    local glass = inventory:getFirstType("RepairableWindows.LargeGlassPane")

    inventory:Remove(glass)
    sendRemoveItemFromContainer(inventory, glass)

    return true
end


---@param character IsoGameCharacter
---@param window IsoWindow
function AddWindowAction.queueNew(character, window)
    local square = AdjacentFreeTileFinder.FindWindowOrDoor(
        window:getSquare(),
        window,
        character
    )

    if not square then
        return
    end

    if not character:getInventory():containsTypeRecurse("RepairableWindows.LargeGlassPane") then
        return
    end

    ISTimedActionQueue.add(ISWalkToTimedAction:new(character, square))
    TimedActionUtils.transferFirstValid(character, "RepairableWindows.LargeGlassPane")
    ISTimedActionQueue.add(
        AddWindowAction:new(character, window)
    )
end


function AddWindowAction:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end

    return 192
end


---@param character IsoGameCharacter
---@param window IsoWindow
---@return AddWindowAction
function AddWindowAction:new(character, window)
    local o = ISBaseTimedAction.new(self, character) --[[@as AddWindowAction]]

    o.window = window

    o.maxTime = o:getDuration()
    o.stopOnAim = true
    o.stopOnRun = true
    o.stopOnWalk = true

    return o
end


-- add a global so that NetTimedAction can find it
_G[AddWindowAction.Type] = AddWindowAction


return AddWindowAction