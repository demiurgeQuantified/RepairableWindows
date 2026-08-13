---@class RepairWindowInHands : ISBaseTimedAction
---@field item Moveable
local RepairMoveableWindow = ISBaseTimedAction:derive("RepairableWindowsRepairMoveableWindow")

---@type table<string, string?>
RepairMoveableWindow.brokenWindowMap = {}

---@param spriteManager IsoSpriteManager
local function populateWindowSprites(spriteManager)
    ---@diagnostic disable-next-line: param-type-mismatch
    ---@type table<string, IsoSprite>
    local sprites = transformIntoKahluaTable(spriteManager:getNamedMap())

    for name, sprite in pairs(sprites) do
        if
            (sprite:hasProperty(IsoFlagType.WindowW) or sprite:hasProperty(IsoFlagType.WindowN))
            and sprite:hasProperty(IsoPropertyType.IS_MOVE_ABLE)
        then
            local smashed = sprite:getProperty(IsoPropertyType.SMASHED_TILE_OFFSET)
            if smashed then
                local smashedSprite = spriteManager:getSprite(sprite:getID() + tonumber(smashed))
                if smashedSprite then
                    RepairMoveableWindow.brokenWindowMap[smashedSprite:getName()] = name
                end
            end
            local glassRemoved = sprite:getProperty(IsoPropertyType.GLASS_REMOVED_OFFSET)
            if glassRemoved then
                local glassRemovedSprite = spriteManager:getSprite(sprite:getID() + tonumber(glassRemoved))
                if glassRemovedSprite then
                    RepairMoveableWindow.brokenWindowMap[glassRemovedSprite:getName()] = name
                end
            end
        end
    end
end

Events.OnLoadedTileDefinitions.Add(populateWindowSprites)

function RepairMoveableWindow:complete()
    local inventory = self.character:getInventory()
    local materials = inventory:getSomeType("Base.GlassPanel", 4)
    if materials:size() < 4 then
        print(
            string.format(
                "[RepairableWindows] WEIRD: player '%s' completed moveable repair without the necessary materials",
                self.character:getUsername()
            )
        )
        return false
    end

    for i = materials:size() - 1, 0, -1 do
        inventory:Remove(materials:get(i))
    end
    sendRemoveItemsFromContainer(inventory, materials)

    inventory:Remove(self.item)
    sendRemoveItemFromContainer(inventory, self.item)

    local unbrokenSprite = RepairMoveableWindow.brokenWindowMap[self.item:getWorldSprite()]
    local item = instanceItem("Moveables." .. unbrokenSprite) ---@as Moveable
    item:ReadFromWorldSprite(unbrokenSprite)
    inventory:addItem(item)
    sendAddItemToContainer(inventory, item)

    return true
end

---@return boolean
function RepairMoveableWindow:isValid()
    if not RepairMoveableWindow.brokenWindowMap[self.item:getWorldSprite()] then
        return false
    end

    local inventory = self.character:getInventory()
    if not inventory:contains(self.item) then
        return false
    end

    if inventory:getCountType("Base.GlassPanel") < 4 then
        return false
    end

    return true
end

function RepairMoveableWindow:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end

    return 192
end

function RepairMoveableWindow:start()
    self:forceCancel()
end

function RepairMoveableWindow:new(character, item)
    local o = ISBaseTimedAction.new(self, character) ---@as RepairWindowInHands

    o.maxTime = o:getDuration()

    o.item = item

    return o
end

_G[RepairMoveableWindow.Type] = RepairMoveableWindow

return RepairMoveableWindow