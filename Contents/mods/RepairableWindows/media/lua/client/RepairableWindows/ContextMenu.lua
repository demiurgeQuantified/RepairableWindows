local RemoveWindowAction = require "RepairableWindows/RemoveWindowAction"
local AddWindowAction = require "RepairableWindows/AddWindowAction"
local WindowUtils = require "RepairableWindows/WindowUtils"
local Colour = require "Starlit/utils/Colour"

local badColour = Colour.fromColorInfo(getCore():getBadHighlitedColor())
local goodColour = Colour.fromColorInfo(getCore():getGoodHighlitedColor())
local windowWeight = ScriptManager.instance:getItem("RepairableWindows.GlassPane"):getActualWeight()

---@type ItemContainer_Predicate
local predicateNotBroken = function(item)
    return not item:isBroken()
end

---@param player IsoPlayer
---@param window IsoWindow
local onRemoveWindow = function(player, window)
    RemoveWindowAction.queueNew(player, window)
end

---@param player IsoPlayer
---@param window IsoWindow
local onAddWindow = function(player, window)
    AddWindowAction.queueNew(player, window)
end

---@type Callback_OnFillWorldObjectContextMenu
local fillContextMenu = function(playerNum, context, worldObjects, test)
    ---@type IsoWindow?
    local window
    for i = 1, #worldObjects do
        local object = worldObjects[i]
        if instanceof(object, "IsoWindow") and not object:getProperties():Is("IsMoveAble") then
            ---@cast object IsoWindow
            -- TODO: review what sprites can be IsoWindows, there might be something weird in there
            window = object
            break
        end
    end
    if not window then return end

    local player = getSpecificPlayer(playerNum)
    local inventory = player:getInventory()

    local option
    if window:isSmashed() then
        if window:isGlassRemoved() and inventory:containsTypeRecurse("RepairableWindows.GlassPane") then
            option = context:addOption(
                getText("IGUI_RepairableWindows_AddWindow"),
                player, onAddWindow, window)
        end
    elseif inventory:containsTagEvalRecurse("Crowbar", predicateNotBroken) then
        option = context:addOption(
            getText("IGUI_RepairableWindows_RemoveWindow"),
            player, onRemoveWindow, window)

        option.toolTip = ISToolTip:new()

        if not player:getInventory():hasRoomFor(player, windowWeight) then
            option.notAvailable = true
            option.toolTip.description = getText("IGUI_ToHeavy")
        else
            option.toolTip.name = getText("IGUI_RepairableWindows_RemoveWindow")

            local skillColour
            local skillLevel = player:getPerkLevel(Perks.Woodwork)
            if skillLevel < 2 then
                option.notAvailable = true
                skillColour = badColour
            else
                skillColour = goodColour
            end

            local breakChance = WindowUtils.getWindowBreakChance(player)
            local colour = Colour.lerpColour(goodColour, badColour, breakChance / 100)
            -- TODO: i would like the values to be right justified, but too much work for right now
            option.toolTip.description = string.format(
                [[%s: <PUSHRGB:%f,%f,%f> <SPACE> %s %d/2 <POPRGB>
                %s: <RGB:%f,%f,%f> <SPACE> %d]],
                getText("IGUI_Skill"), skillColour[1], skillColour[2], skillColour[3], Perks.Woodwork:getName(), skillLevel,
                getText("IGUI_ChanceToBreak"), colour[1], colour[2], colour[3], breakChance)
        end
    end

    if option then
        if window:isBarricaded() then
            option.notAvailable = true
            option.toolTip = ISToolTip:new()
            option.toolTip.description = getText("IGUI_WindowBarricaded")
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(fillContextMenu)
