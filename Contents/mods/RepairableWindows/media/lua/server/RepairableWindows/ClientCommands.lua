if isClient() then return end

local WindowUtils = require "RepairableWindows/WindowUtils"

local log = require "RepairableWindows/Log"
local rand = newrandom()

local ClientCommands = {}

---@param player IsoPlayer
---@param window IsoWindow
---@param item InventoryItem
ClientCommands.handleAddWindow = function(player, window, item)
    if not window:isSmashed() or not window:isGlassRemoved() then
        log("Attempt to add window at %d,%d,%d,%d failed: window is not broken", "debug",
            window:getX(), window:getY(), window:getZ(), window:getObjectIndex())
        return
    end
    window:setGlassRemoved(false)
    window:setSmashed(false)
    player:sendObjectChange("removeItemID", {id = item:getID(), type = item:getFullType()})
    sendServerCommand("RepairableWindows", "updateWindowState",
        {x = window:getX(), y = window:getY(), z = window:getZ(),
            i = window:getObjectIndex(), state = "glass"})
end

---@param player IsoPlayer
---@param window IsoWindow
ClientCommands.handleRemoveWindow = function(player, window)
    if window:isSmashed() then
        log("Attempt to remove window at %d,%d,%d,%d failed: window is broken", "debug",
            window:getX(), window:getY(), window:getZ(), window:getObjectIndex())
        return
    end

    if rand:random(100) <= WindowUtils.getWindowBreakChance(player) then
        window:smashWindow()
        return
    end

    window:setSmashed(true)
    window:setGlassRemoved(true)
    player:sendObjectChange(
        "addItemOfType", {type = "RepairableWindows.GlassPane"})
    sendServerCommand("RepairableWindows", "updateWindowState",
    {x = window:getX(), y = window:getY(), z = window:getZ(),
        i = window:getObjectIndex(), state = "noGlass"})
end

---@type Callback_OnClientCommand
ClientCommands.handleClientCommand = function(module, command, player, args)
    if module ~= "RepairableWindows" then return end
    if command == "addWindow" then
        local window = WindowUtils.getWindow(args.x, args.y, args.z, args.i)
        if not window then return end
        ClientCommands.handleAddWindow(player, window, args.item)
    elseif command == "removeWindow" then
        local window = WindowUtils.getWindow(args.x, args.y, args.z, args.i)
        if not window then return end
        ClientCommands.handleRemoveWindow(player, window)
    else
        log("Received unknown client command %s", "debug", command)
    end
end

Events.OnClientCommand.Add(ClientCommands.handleClientCommand)

return ClientCommands