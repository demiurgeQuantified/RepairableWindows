local ActionUI = require("Starlit/client/action/ActionUI")
local Colour = require("Starlit/utils/Colour")

local WindowUtils = require("RepairableWindows/WindowUtils")

local AddWindowAction = require("RepairableWindows/actions/AddWindowAction")
local RemoveWindowAction = require("RepairableWindows/actions/RemoveWindowAction")

local CORE = getCore()


local addConfig = ActionUI.TooltipConfiguration{
    highlight = {
        object = "window"
    },
    objectAs = "window",
    showFailConditions = {
        noSuccesses = true,
        onlyOne = false,
        required = {
            objects = {
                ["window"] = true
            }
        }
    }
}

ActionUI.addObjectAction(AddWindowAction, addConfig)


local removeConfig = addConfig{
    getTooltipText = function(state)
        local goodColour = Colour.fromColorInfo(CORE:getGoodHighlitedColor())
        local badColour = Colour.fromColorInfo(CORE:getBadHighlitedColor())
        local breakChance = WindowUtils.getWindowBreakChance(state.character)
        local colour = Colour.lerpColour(goodColour, badColour, breakChance / 100)

        return string.format(
            [[%s: <SPACE> <GHC> %s %d/2
            <RGB:1,1,1> %s: <SPACE> <RGB:%f,%f,%f> %d]],
            getText("IGUI_Skill"), Perks.Woodwork:getName(), state.character:getPerkLevel(Perks.Woodwork),
            getText("IGUI_ChanceToBreak"), colour[1], colour[2], colour[3], breakChance)
    end
}

ActionUI.addObjectAction(RemoveWindowAction, removeConfig)
