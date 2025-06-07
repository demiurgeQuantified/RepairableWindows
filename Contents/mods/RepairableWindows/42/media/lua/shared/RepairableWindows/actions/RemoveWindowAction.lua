local Action = require("Starlit/action/Action")
local Predicates = require("Starlit/action/Predicates")

local WindowUtils = require("RepairableWindows/WindowUtils")

local rand = newrandom()


local RemoveWindowAction = Action.Action{
    name = getText("IGUI_RepairableWindows_RemoveWindow"),
    time = 192,
    stopOnAim = true,
    stopOnWalk = true,
    stopOnRun = true,
    animation = "RemoveBarricade",
    animationVariables = {
        RemoveBarricade = "CrowbarMid",
    },
    requiredItems = {
        crowbar = Action.RequiredItem{
            tags = {"Crowbar"},
            predicates = {
                Predicates.item.NotBroken
            }
        }
    },
    primaryItem = "crowbar",
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
                               and not object:isSmashed()
                    end,
                    description = getText("IGUI_RepairableWindows_Predicate_HasGlass")
                },
                Action.Predicate{
                    evaluate = function(self, object)
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
        if rand:random(100) <= WindowUtils.getWindowBreakChance(state.character) then
            window:smashWindow()
            return
        end
        window:setSmashed(true)
        window:setGlassRemoved(true)
        state.character:getInventory():AddItem("RepairableWindows.LargeGlassPane")
    end
}

assert(Action.isComplete(RemoveWindowAction))


return RemoveWindowAction