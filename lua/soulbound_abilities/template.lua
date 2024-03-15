local ABILITY = {}

ABILITY.Name = ""
ABILITY.Id = ""
ABILITY.Description = ""
ABILITY.Icon = ""

function ABILITY:Bought(soulbound)

end

function ABILITY:Condition(soulbound, target)
    return true
end

function ABILITY:Use(soulbound, target)

end

function ABILITY:DrawHUD(soulbound, x, y, width, height, key)

end

--SOULBOUND:RegisterAbility(ABILITY)