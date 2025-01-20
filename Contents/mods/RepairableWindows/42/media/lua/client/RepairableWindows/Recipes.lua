local magazine = ScriptManager.instance:getItem("Base.GlassmakingMag2")
if magazine then
    magazine:getTeachedRecipes():add("MakeLargeGlassPane")
end

-- give recipe to players who already have the small recipe but not the large one (because they read the magazine before it was added to it)
Events.OnCreatePlayer.Add(function(playerIndex, player)
    local knownRecipes = player:getKnownRecipes()
    if knownRecipes:contains("MakeGlassPanel")
            and not knownRecipes:contains("MakeLargeGlassPane") then
        knownRecipes:add("MakeLargeGlassPane")
    end
end)
