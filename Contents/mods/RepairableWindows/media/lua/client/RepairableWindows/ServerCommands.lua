local WindowUtils = require "RepairableWindows/WindowUtils"

local log = require "RepairableWindows/Log"

local ServerCommands = {}

---@type Callback_OnServerCommand
ServerCommands.handleServerCommand = function(module, command, args)
    if module ~= "RepairableWindows" then return end
    if command == "updateWindowState" then
        WindowUtils.setWindowState(args.x, args.y, args.z, args.i, args.state)
    else
        log("Received unknown server command %s", "debug", command)
    end
end

Events.OnServerCommand.Add(ServerCommands.handleServerCommand)

return ServerCommands