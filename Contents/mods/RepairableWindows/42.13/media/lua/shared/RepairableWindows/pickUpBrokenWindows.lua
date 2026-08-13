local RepairMoveableWindows = require("RepairableWindows/RepairMoveableWindow")

local old_pickUpMoveableInternal = ISMoveableSpriteProps.pickUpMoveableInternal

---@param character IsoGameCharacter
---@param square IsoGridSquare
---@param object IsoObject
---@param sprInstance IsoSpriteInstance
---@param spriteName string
---@param createItem boolean
---@param rotating boolean
---@return InventoryItem?
function ISMoveableSpriteProps:pickUpMoveableInternal(character, square, object, sprInstance, spriteName, createItem, rotating)
    if not RepairMoveableWindows.brokenWindowMap[spriteName] then
        return old_pickUpMoveableInternal(self, character, square, object, sprInstance, spriteName, createItem, rotating)
    end

    -- mostly copied from instanceItem

    local item
    if self.customItem then
        item = instanceItem(self.customItem)
    else
        item = instanceItem("Moveables." .. self.spriteName);
    end

    spriteName = spriteName or self.spriteName
    if not (item and instanceof(item, "Moveable") and item:ReadFromWorldSprite(spriteName)) then
        return nil
    end

    item:setActualWeight(self.weight)
    item:setCondition(0, false)

    -- rest is copied from pickUpMoveableInternal

    GameEntityFactory.TransferComponents(object, item)

    if object:hasModData() and object:getModData().movableData then
        item:getModData().movableData = copyTable(object:getModData().movableData)
    end

    for i = 0, object:getContainerCount()-1 do
        if object:getContainerByIndex(i) and object:getContainerByIndex(i):getCustomName() then
            local cont = object:getContainerByIndex(i)
            local key = cont:getType() .. "_customContainerName"
            item:getModData()[key] = object:getContainerByIndex(i):getCustomName()
        end
    end

    if object:hasModData() and object:getModData().itemCondition then
        item:setConditionMax(object:getModData().itemCondition.max);
        item:setCondition(object:getModData().itemCondition.value);
    end

    if instanceof(object, "IsoStove") and object:isBroken() then
        item:setCondition(0);
    end

    if createItem then
        if self.isMultiSprite then
            square:AddWorldInventoryItem(item, ZombRandFloat(0.1,0.9), ZombRandFloat(0.1,0.9), 0);
        else
            character:getInventory():AddItem(item);        -- add the item if it aint got broken
            sendAddItemToContainer(character:getInventory(), item);
        end
    end

    square:transmitRemoveItemFromSquare(object)

    square:RecalcProperties();
    square:RecalcAllWithNeighbours(true);

    triggerEvent("OnContainerUpdate")

    IsoGenerator.updateGenerator(square)

    return item
end
