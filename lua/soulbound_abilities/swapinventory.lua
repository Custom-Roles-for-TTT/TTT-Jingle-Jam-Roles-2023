local ABILITY = {}

ABILITY.Name = "Swap Inventory"
ABILITY.Id = "swapinventory"
ABILITY.Description = "Swap the inventory of two different players. Doesn't swap role specific weapons"
ABILITY.Icon = "vgui/ttt/icon_swapinventory.png"

local swapinventory_uses = CreateConVar("ttt_soulbound_swapinventory_uses", "1", FCVAR_REPLICATED, "How many uses should of the swap inventory ability should the Soulbound get. (Set to 0 for unlimited uses)", 0, 10)
local swapinventory_cooldown = CreateConVar("ttt_soulbound_swapinventory_cooldown", "0", FCVAR_NONE, "How long should the Soulbound have to wait between uses of the swap inventory ability", 0, 10)

table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_swapinventory_uses",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_swapinventory_cooldown",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 1
})

if SERVER then
    function ABILITY:Bought(soulbound)
        soulbound:SetNWInt("TTTSoulboundSwapInventoryUses", swapinventory_uses:GetInt())
        soulbound:SetNWFloat("TTTSoulboundSwapInventoryNextUse", CurTime())
        soulbound:SetNWString("TTTSoulboundSwapInventoryTarget", "")
    end

    function ABILITY:Condition(soulbound, target)
        if swapinventory_uses:GetInt() > 0 and soulbound:GetNWInt("TTTSoulboundSwapInventoryUses", 0) <= 0 then return false end
        if CurTime() < soulbound:GetNWFloat("TTTSoulboundSwapInventoryNextUse") then return false end
        if not target or not IsPlayer(target) then return false end
        return true
    end

    local function SwapWeapons(ply, weapons)
        local roleWeapons = {}
        for _, w in ipairs(ply:GetWeapons()) do
            if w.Category == WEAPON_CATEGORY_ROLE then
                table.insert(roleWeapons, WEPS.GetClass(w))
            end
        end

        local activeClass = nil
        local activeKind = WEAPON_UNARMED
        if IsValid(ply:GetActiveWeapon()) then
            activeClass = WEPS.GetClass(ply:GetActiveWeapon())
            activeKind = WEPS.TypeForWeapon(activeClass)
        end

        ply:StripWeapons()
        -- Reset FOV to unscope
        ply:SetFOV(0, 0.2)

        for _, c in ipairs(roleWeapons) do
            ply:Give(c)
        end

        ply:Give("weapon_ttt_unarmed")
        ply:Give("weapon_zm_carry")
        ply:Give("weapon_zm_improvised")

        for _, v in ipairs(weapons) do
            if v.Category ~= WEAPON_CATEGORY_ROLE then
                local class = WEPS.GetClass(v)
                ply:Give(class)
            end
        end

        -- Try to find the correct weapon to select so the transition is less jarring
        local selectClass = nil
        for _, w in ipairs(ply:GetWeapons()) do
            local class = WEPS.GetClass(w)
            local kind = WEPS.TypeForWeapon(class)
            if (activeClass ~= nil and class == activeClass) or kind == activeKind then
                selectClass = class
            end
        end

        if selectClass ~= nil then
            timer.Simple(0.25, function()
                ply:SelectWeapon(selectClass)
            end)
        else
            ply:SelectWeapon("weapon_ttt_unarmed")
        end
    end

    function ABILITY:Use(soulbound, target1)
        local t1sid64 = target1:SteamID64()
        local t2sid64 = soulbound:GetNWString("TTTSoulboundSwapInventoryTarget", "")
        if #t2sid64 == 0 then
            soulbound:SetNWString("TTTSoulboundSwapInventoryTarget", t1sid64)
        elseif t1sid64 ~= t2sid64 then
            local target2 = player.GetBySteamID64(t2sid64)
            if not target2 or not IsPlayer(target2) or not target2:Alive() or target2:IsSpec() then
                soulbound:SetNWString("TTTSoulboundSwapInventoryTarget", t1sid64)
            else
                local t1weps = target1:GetWeapons()
                SwapWeapons(target1, target2:GetWeapons())
                SwapWeapons(target2, t1weps)

                local uses = soulbound:GetNWInt("TTTSoulboundSwapInventoryUses", 0)
                uses = math.max(uses - 1, 0)
                soulbound:SetNWInt("TTTSoulboundSwapInventoryUses", uses)
                soulbound:SetNWFloat("TTTSoulboundSwapInventoryNextUse", CurTime() + swapinventory_cooldown:GetFloat())
                soulbound:SetNWString("TTTSoulboundSwapInventoryTarget", "")
            end
        end
    end

    function ABILITY:Cleanup(soulbound)
        soulbound:SetNWInt("TTTSoulboundSwapInventoryUses", 0)
        soulbound:SetNWFloat("TTTSoulboundSwapInventoryNextUse", 0)
        soulbound:SetNWString("TTTSoulboundSwapInventoryTarget", "")
    end
end

if CLIENT then
    local ammo_colors = {
        border = COLOR_WHITE,
        background = Color(100, 60, 0, 222),
        fill = Color(205, 155, 0, 255)
    }

    function ABILITY:DrawHUD(soulbound, x, y, width, height, key)
        local max_uses = swapinventory_uses:GetInt()
        local uses = soulbound:GetNWInt("TTTSoulboundSwapInventoryUses", 0)
        local margin = 6
        local ammo_height = 28
        if max_uses == 0 then
            CRHUD:PaintBar(8, x + margin, y + margin, width - (margin * 2), ammo_height, ammo_colors, 1)
            CRHUD:ShadowedText("Unlimited Uses", "HealthAmmo", x + (margin * 2), y + margin + (ammo_height / 2), COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            CRHUD:PaintBar(8, x + margin, y + margin, width - (margin * 2), ammo_height, ammo_colors, uses / max_uses)
            CRHUD:ShadowedText(tostring(uses) .. "/" .. tostring(max_uses), "HealthAmmo", x + (margin * 2), y + margin + (ammo_height / 2), COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        local ready = true
        local text
        local next_use = soulbound:GetNWFloat("TTTSoulboundSwapInventoryNextUse")
        local cur_time = CurTime()
        if max_uses > 0 and uses <= 0 then
            ready = false
            text = "Out of uses"
        elseif cur_time < next_use then
            ready = false
            local s = next_use - cur_time
            local ms = (s - math.floor(s)) * 100
            s = math.floor(s)
            text = "On cooldown for " .. string.format("%02i.%02i", s, ms) .. " seconds"
        else
            local target1 = soulbound:GetObserverMode() ~= OBS_MODE_ROAMING and soulbound:GetObserverTarget() or nil
            local t2sid64 = soulbound:GetNWString("TTTSoulboundSwapInventoryTarget", "")
            if not target1 or not IsPlayer(target1) then
                ready = false
                text = "Spectate a player"
            elseif #t2sid64 == 0 then
                text = "Press '" .. key .. "' to choose " .. target1:Nick() .. " as your first target"
            else
                local target2 = player.GetBySteamID64(t2sid64)
                if not target2 or not IsPlayer(target2) or not target2:Alive() or target2:IsSpec() then
                    text = "Press '" .. key .. "' to choose " .. target1:Nick() .. " as your first target"
                elseif target1 == target2 then
                    ready = false
                    text = "Spectate another player"
                else
                    text = "Press '" .. key .. "' to swap " .. target1:Nick() .. " and " .. target2:Nick()
                end
            end
        end

        draw.SimpleText(text, "TabLarge", x + margin, y + height - margin, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        return ready
    end
end

SOULBOUND:RegisterAbility(ABILITY)