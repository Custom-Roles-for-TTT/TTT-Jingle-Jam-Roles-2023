local ABILITY = {}

ABILITY.Name = ""
ABILITY.Id = ""
ABILITY.Description = ""
ABILITY.Icon = ""

if SERVER then
    function ABILITY:Bought(soulbound)

    end

    function ABILITY:Condition(soulbound, target)
        return true
    end

    function ABILITY:Use(soulbound, target)

    end
end

if CLIENT then
    function ABILITY:DrawHUD(soulbound, x, y, width, height, key)

    end
end

--SOULBOUND:RegisterAbility(ABILITY)

-- Putting this here to luacheck will stop being mad at me
if false then print(ABILITY) end