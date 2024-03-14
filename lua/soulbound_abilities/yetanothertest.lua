local ABILITY = {}

ABILITY.Name = "Yet Another Test"
ABILITY.Id = "yetanothertest"
ABILITY.Description = "Yet another test ability"
ABILITY.Icon = "vgui/ttt/icon_cbar"

function ABILITY:Condition()
    return true
end

function ABILITY:Use()
    for _, v in ipairs(player.GetAll()) do
        v:PrintMessage(HUD_PRINTTALK, "There are so many abilities")
    end
end

SOULBOUND:RegisterAbility(ABILITY)