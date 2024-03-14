local ABILITY = {}

ABILITY.Name = "Even More Tests"
ABILITY.Id = "evenmoretests"
ABILITY.Description = "Even more test abilities"
ABILITY.Icon = "vgui/ttt/icon_cbar"

function ABILITY:Condition()
    return true
end

function ABILITY:Use()
    for _, v in ipairs(player.GetAll()) do
        v:PrintMessage(HUD_PRINTTALK, "So many abilities")
    end
end

SOULBOUND:RegisterAbility(ABILITY)