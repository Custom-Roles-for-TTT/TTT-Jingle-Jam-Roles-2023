local ABILITY = {}

ABILITY.Name = "Test"
ABILITY.Id = "test"
ABILITY.Description = "Test ability"
ABILITY.Icon = "vgui/ttt/icon_cbar"

function ABILITY:Condition()
    return true
end

function ABILITY:Use()
    for _, v in ipairs(player.GetAll()) do
        v:PrintMessage(HUD_PRINTTALK, "Wow such a cool ability")
    end
end

SOULBOUND:RegisterAbility(ABILITY)