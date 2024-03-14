local ROLE = {}

ROLE.nameraw = "soulbound"
ROLE.name = "Soulbound"
ROLE.nameplural = "Soulbounds"
ROLE.nameext = "a Soulbound"
ROLE.nameshort = "sbd"

ROLE.desc = [[You are an {role}! {comrades}

Seeing this message should be impossible! Please let
us know how you are seeing this so we can fix it.

Press {menukey} to receive your special equipment!]]

ROLE.team = ROLE_TEAM_TRAITOR

ROLE.convars = {}

ROLE.translations = {}

-- This role shouldn't be able to spawn
ROLE.blockspawnconvars = true
-- This role is only for dead players so we don't need health ConVars
ROLE.blockhealthconvars = true
-- This role is only for dead players so we don't need shop ConVars
ROLE.blockshopconvars = true

RegisterRole(ROLE)

hook.Add("TTTRoleSpawnsArtificially", "Soulbound_TTTRoleSpawnsArtificially", function(role)
    if role == ROLE_SOULBOUND and util.CanRoleSpawn(ROLE_SOULMAGE) then
        return true
    end
end)

if SERVER then
    hook.Add("TTTPlayerSpawnForRound", "Soulbound_TTTPlayerSpawnForRound", function(ply, dead_only)
        if not IsPlayer(ply) then return end
        if ply:IsSoulbound() then
            ply:SetRole(ROLE_TRAITOR)
            SendFullStateUpdate()
        end
    end)
end

if CLIENT then
    local client
    
    ----------
    -- SHOP --
    ----------

    local dshop
    local function OpenSoulboundShop()
        chat.AddText("Shop opened!")
    end

    hook.Add("OnContextMenuOpen", "Soulbound_OnContextMenuOpen", function()
        if GetRoundState() ~= ROUND_ACTIVE then return end

        if not client then
            client = LocalPlayer()
        end
        if not client:IsSoulbound() then return end

        if IsValid(dshop) then
            dshop:Close()
        else
            OpenSoulboundShop()
        end
    end)

    ---------------
    -- ABILITIES --
    ---------------

    local function UseAbility(id)
        chat.AddText("Ability " .. tostring(id) .. " used!")
    end

    hook.Add("PlayerBindPress", "Soulbound_PlayerBindPress", function(ply, bind, pressed)
        if not IsPlayer(ply) then return end
        if not ply:IsSoulbound() then return end
        if not pressed then return end

        if string.sub(bind, 1, 4) == "slot" then
            local id = tonumber(string.sub(bind, 5, -1)) or 1
            UseAbility(id)
        end
    end)
    
    ---------
    -- HUD --
    ---------

    hook.Add("HUDDrawScoreBoard", "Soulbound_HUDDrawScoreBoard", function() -- Use HUDDrawScoreBoard instead of HUDPaint so it draws above the TTT HUD
        if GetRoundState() ~= ROUND_ACTIVE then return end
        
        if not client then
            client = LocalPlayer()
        end
        if not client:IsSoulbound() then return end

        local margin = 10
        local height = 32
        draw.RoundedBox(8, margin, ScrH() - height - margin, 170, height, ROLE_COLORS[ROLE_SOULBOUND])
        if #ROLE_STRINGS[ROLE_SOULBOUND] > 10 then
            CRHUD:ShadowedText(ROLE_STRINGS[ROLE_SOULBOUND], "TraitorStateSmall", margin + 84, ScrH() - height - margin + 2, COLOR_WHITE, TEXT_ALIGN_CENTER)
        else
            CRHUD:ShadowedText(ROLE_STRINGS[ROLE_SOULBOUND], "TraitorState", margin + 84, ScrH() - height - margin, COLOR_WHITE, TEXT_ALIGN_CENTER)
        end
    end)

    --------------
    -- TUTORIAL --
    --------------

    hook.Add("TTTTutorialRoleText", "Soulbound_TTTTutorialRoleText", function(role, titleLabel)
        if role == ROLE_SOULBOUND then
            local roleColor = ROLE_COLORS[ROLE_TRAITOR]

            local html = "The " .. ROLE_STRINGS[ROLE_SOULBOUND] .. " is a member of the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor team</span> who can use special powers while dead to help the traitor team."

            html = html .. "<span style='display: block; margin-top: 10px;'>The " .. ROLE_STRINGS[ROLE_SOULBOUND] .. " can only ever exist as a dead player. If a living player somehow becomes " .. ROLE_STRINGS_EXT[ROLE_SOULBOUND] .. ", they will instantly be changed into <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>" .. ROLE_STRINGS_EXT[ROLE_TRAITOR] .. ".</span>"

            return html
        end
    end)
end