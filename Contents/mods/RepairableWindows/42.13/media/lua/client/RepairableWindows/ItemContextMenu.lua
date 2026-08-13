local RepairMoveableWindow = require("RepairableWindows/RepairMoveableWindow")


---@param character IsoGameCharacter
---@param item Moveable
local function queueRepair(character, item)
    ISTimedActionQueue.add(
        RepairMoveableWindow:new(character, item)
    )
end

---@param playerIndex integer
---@param context ISContextMenu
---@param items InventoryItem[] | umbrella.ContextMenuItemStack[]
local function addMoveableWindowRepairOption(playerIndex, context, items)
    local primaryItem
    if instanceof(items[1], "InventoryItem") then
        ---@cast items InventoryItem[]
        primaryItem = items[1]
    else
        ---@cast items umbrella.ContextMenuItemStack[]
        primaryItem = items[1].items[1]
    end

    -- can be nil if there are no items selected
    if not primaryItem then
        return
    end

    if not instanceof(primaryItem, "Moveable") then
        return
    end
    ---@cast primaryItem Moveable

    if not RepairMoveableWindow.brokenWindowMap[primaryItem:getWorldSprite()] then
        return
    end

    -- TODO: don't allow if not enough materials, show tooltip why
    
    context:addOption(
        getText("ContextMenu_Repair"),
        getSpecificPlayer(playerIndex),
        queueRepair,
        primaryItem
    )
end

Events.OnFillInventoryObjectContextMenu.Add(addMoveableWindowRepairOption)
