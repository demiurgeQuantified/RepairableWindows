local Action = require("Starlit/action/Action")


local AddWindowAction = Action.Action{
    name = getText("IGUI_RepairableWindows_AddWindow"),
    time = 192,
    stopOnAim = true,
    stopOnRun = true,
    stopOnWalk = true,
    requiredItems = {
        glass = Action.RequiredItem{
            types = {"RepairableWindows.LargeGlassPane"},
            mainInventory = true,
            count = 1,
            consumed = true
        }
    },
    primaryItem = "EMPTY",
    secondaryItem = "EMPTY",
    requiredObjects = {
        window = Action.RequiredObject{
            predicates = {
                Action.Predicate{
                    evaluate = function(self, object)
                        return instanceof(object, "IsoWindow")
                    end,
                    description = getText("IGUI_RepairableWindows_Predicate_IsWindow")
                },
                Action.Predicate{
                    evaluate = function(self, object)
                        -- we have to check instanceof twice because we don't short circuit anymore :(
                        return instanceof(object, "IsoWindow") ---@cast object IsoWindow
                               and object:isSmashed()
                    end,
                    description = getText("IGUI_RepairableWindows_Predicate_IsSmashed")
                },
                Action.Predicate{
                    evaluate = function (self, object)
                        return instanceof(object, "IsoWindow") ---@cast object IsoWindow
                                and not object:isBarricaded()
                    end,
                    description = getText("IGUI_RepairableWindows_Predicate_NotBarricaded")
                }
            }
        }
    },
    faceObject = "window",
    walkToObject = "window",
    requiredSkills = {
        [Perks.Woodwork] = 2
    },
    complete = function(state)
        local window = state.objects.window --[[@as IsoWindow]]
        window:setGlassRemoved(false)
        window:setSmashed(false)
    end
}

assert(Action.isComplete(AddWindowAction))


return AddWindowAction