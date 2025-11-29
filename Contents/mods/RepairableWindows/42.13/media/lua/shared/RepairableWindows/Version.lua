local Version = require("Starlit/Version")

Events.OnGameStart.Add(function()
    -- 1.4.5 is required due to previous versions not being compatible with 42.13
    Version.ensureVersion(1, 4, 5)
end)
