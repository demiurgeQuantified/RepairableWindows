local Colour = require("Starlit/utils/Colour")

local RemoveWindowAction = require("RepairableWindows/RemoveWindowAction")
local AddWindowAction = require("RepairableWindows/AddWindowAction")


local BAD_COLOUR = Colour.fromColorInfo(getCore():getBadHighlitedColor())
local GOOD_COLOUR = Colour.fromColorInfo(getCore():getGoodHighlitedColor())

local WINDOW_WEIGHT = ScriptManager.instance:getItem("RepairableWindows.LargeGlassPane"):getActualWeight()


---@param item InventoryItem
---@return boolean
local function predicateNotBroken(item)
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


---@param context ISContextMenu
---@param character IsoGameCharacter
---@param window IsoWindow
---@return umbrella.ISContextMenu.Option
local function addRemoveWindowOption(context, character, window)
    local option = context:addOption(
        getText("IGUI_RepairableWindows_RemoveWindow"),
        character, onRemoveWindow, window)

    option.toolTip = ISToolTip:new()

    if not character:getInventory():hasRoomFor(character, WINDOW_WEIGHT) then
        option.notAvailable = true
        option.toolTip.description = getText("IGUI_ToHeavy")
    else
        option.toolTip.name = getText("IGUI_RepairableWindows_RemoveWindow")

        local skillColour
        local skillLevel = character:getPerkLevel(Perks.Woodwork)
        if RemoveWindowAction.canPerform(character) then
            skillColour = GOOD_COLOUR
        else
            option.notAvailable = true
            skillColour = BAD_COLOUR
        end

        local breakChance = RemoveWindowAction.getWindowBreakChance(character)
        local colour = Colour.lerpColour(GOOD_COLOUR, BAD_COLOUR, breakChance / 100)
        -- TODO: i would like the values to be right justified, but too much work for right now
        option.toolTip.description = string.format(
            [[%s: <PUSHRGB:%f,%f,%f> <SPACE> %s %d/2 <POPRGB>
            %s: <RGB:%f,%f,%f> <SPACE> %d]],
            getText("IGUI_Skill"), skillColour[1], skillColour[2], skillColour[3], Perks.Woodwork:getName(), skillLevel,
            getText("IGUI_ChanceToBreak"), colour[1], colour[2], colour[3], breakChance)
    end

    return option
end


---@param playerIndex integer
---@param context ISContextMenu
---@param worldObjects IsoObject[]
---@param test boolean
local function fillContextMenu(playerIndex, context, worldObjects, test)
    ---@type IsoWindow?
    local window
    for i = 1, #worldObjects do
        local object = worldObjects[i]
        if instanceof(object, "IsoWindow") and not object:hasProperty("IsMoveAble") then
            ---@cast object IsoWindow
            window = object
            break
        end
    end

    if not window then
        return
    end

    local player = getSpecificPlayer(playerIndex)
    local inventory = player:getInventory()

    local option
    if window:isSmashed() then
        if window:isGlassRemoved() and inventory:containsTypeRecurse("RepairableWindows.LargeGlassPane") then
            option = context:addOption(
                getText("IGUI_RepairableWindows_AddWindow"),
                player, onAddWindow, window)
        end
    elseif inventory:containsTagEvalRecurse(ItemTag.CROWBAR, predicateNotBroken) then
        option = addRemoveWindowOption(context, player, window)
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
