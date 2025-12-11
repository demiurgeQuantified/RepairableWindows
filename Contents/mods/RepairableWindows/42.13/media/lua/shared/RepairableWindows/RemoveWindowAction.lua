local TimedActionUtils = require("Starlit/timedActions/TimedActionUtils")


local WINDOW_WEIGHT = ScriptManager.instance:getItem("RepairableWindows.LargeGlassPane"):getActualWeight()

local rand = newrandom()



---@param item InventoryItem
---@return boolean
local function predicateNotBroken(item)
    return not item:isBroken()
end


---@namespace repairableWindows


---@class RemoveWindowAction : ISBaseTimedAction
---@field window IsoWindow
local RemoveWindowAction = ISBaseTimedAction:derive("RepairableWindowsRemoveWindowAction")


---@param character IsoGameCharacter
---@return boolean
function RemoveWindowAction.canPerform(character)
    local skillLevel = character:getPerkLevel(Perks.Woodwork)
    return skillLevel >= 2
end


---@param character IsoGameCharacter
---@return number # 0-100 chance to break the window
function RemoveWindowAction.getWindowBreakChance(character)
    if SandboxVars.RepairableWindows.BreakChance == 1 then
        return 55 - character:getPerkLevel(Perks.Woodwork) * 5
    elseif SandboxVars.RepairableWindows.BreakChance == 2 then
        return 65 - character:getPerkLevel(Perks.Woodwork) * 10
    end

    return 0
end


function RemoveWindowAction:isValidStart()
    local primaryHandItem = self.character:getPrimaryHandItem()
    if not primaryHandItem:hasTag(ItemTag.CROWBAR) or primaryHandItem:isBroken() then
        return false
    end

    if not self.character:getInventory():hasRoomFor(self.character, WINDOW_WEIGHT) then
        return false
    end

    return true
end


function RemoveWindowAction:waitToStart()
    self.character:faceThisObject(self.window)
    return self.character:shouldBeTurning()
end


function RemoveWindowAction:isValid()
    -- ensure the object hasn't been removed and that the window hasn't been smashed
    -- TODO: check way more stuff here for security
    return self.window:getSquare() and not self.window:isSmashed()
end


function RemoveWindowAction:complete()
    if rand:random(100) <= RemoveWindowAction.getWindowBreakChance(self.character) then
        self.window:smashWindow()
    else
        self.window:setSmashed(true)
        self.window:setGlassRemoved(true)

        local inventory = self.character:getInventory()
        local item = inventory:AddItem("RepairableWindows.LargeGlassPane")
        sendAddItemToContainer(inventory, item)
    end

    self.window:sync()
end


function RemoveWindowAction:start()
    self:setActionAnim("RemoveBarricade")
    self:setAnimVariable("RemoveBarricade", "CrowbarMid")
end


---@param character IsoGameCharacter
---@param window IsoWindow
function RemoveWindowAction.queueNew(character, window)
    local square = AdjacentFreeTileFinder.FindWindowOrDoor(
        window:getSquare(),
        window,
        character
    )

    if not square then
        return
    end

    local crowbar = character:getInventory():getFirstTagEvalRecurse(ItemTag.CROWBAR, predicateNotBroken)
    if not crowbar then
        return
    end

    ISTimedActionQueue.add(ISWalkToTimedAction:new(character, square))
    TimedActionUtils.transferAndEquip(character, crowbar, "primary")
    ISTimedActionQueue.add(
        RemoveWindowAction:new(character, window)
    )
end


function RemoveWindowAction:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end

    return 192
end


---@param character IsoGameCharacter
---@param window IsoWindow
---@return RemoveWindowAction
function RemoveWindowAction:new(character, window)
    local o = ISBaseTimedAction.new(self, character) --[[@as RemoveWindowAction]]

    o.window = window

    o.maxTime = o:getDuration()
    o.stopOnAim = true
    o.stopOnRun = true
    o.stopOnWalk = true

    return o
end


_G[RemoveWindowAction.Type] = RemoveWindowAction


return RemoveWindowAction