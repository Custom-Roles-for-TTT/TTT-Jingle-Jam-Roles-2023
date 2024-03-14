local ABILITY = {}

ABILITY.Name = "New Test"
ABILITY.Id = "newtest"
ABILITY.Description = "New test ability"
ABILITY.Icon = "vgui/ttt/icon_cbar"

function ABILITY:Condition()
    return true
end

function ABILITY:Use()
    for _, v in ipairs(player.GetAll()) do
        v:PrintMessage(HUD_PRINTTALK, "Wow such a cool new ability")
    end
end

SOULBOUND:RegisterAbility(ABILITY)