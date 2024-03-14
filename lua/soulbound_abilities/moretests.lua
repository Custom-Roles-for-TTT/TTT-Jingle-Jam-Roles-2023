local ABILITY = {}

ABILITY.Name = "More Tests"
ABILITY.Id = "moretests"
ABILITY.Description = "More test abilities"
ABILITY.Icon = "vgui/ttt/icon_cbar"

function ABILITY:Condition()
    return true
end

function ABILITY:Use()
    for _, v in ipairs(player.GetAll()) do
        v:PrintMessage(HUD_PRINTTALK, "We need more abilities")
    end
end

SOULBOUND:RegisterAbility(ABILITY)