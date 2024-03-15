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

local soulbound_max_abilities = CreateConVar("ttt_soulbound_max_abilities", "3", FCVAR_REPLICATED, "The maximum number of abilities the Soulbound can buy. (Set to 0 to disable abilities)", 0, 9)

ROLE.convars = {}
table.insert(ROLE.convars, {
    cvar = "ttt_soulbound_max_abilities",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})

ROLE.translations = {
    ["english"] = {
        ["abilities_title"] = "Ability Selection",
        ["abilities_confirm"] = "Select ability",
        ["abilities_random"] = "Select random ability",
    }}

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

--------------------------
-- ABILITY REGISTRATION --
--------------------------

SOULBOUND = {
    Abilities = {}
}

function SOULBOUND:RegisterAbility(ability)
    ability.Id = ability.Id or ability.id or ability.ID

    if SOULBOUND.Abilities[ability.Id] then
        ErrorNoHalt("[SOULBOUND] Soulbound ability already exists with ID '" .. ability.Id .. "'\n")
        return
    end

    local enabled = CreateConVar("ttt_soulbound_" .. ability.Id .. "_enabled", "1")
    ability.Enabled = function()
        return enabled:GetBool()
    end

    SOULBOUND.Abilities[ability.Id] = ability
end

local abilityFiles, _ = file.Find("soulbound_abilities/*.lua", "LUA")
for _, fil in ipairs(abilityFiles) do
    if SERVER then AddCSLuaFile("soulbound_abilities/" .. fil) end
    include("soulbound_abilities/" .. fil)
end

if SERVER then
    util.AddNetworkString("TTT_SoulboundBuyAbility")
    util.AddNetworkString("TTT_SoulboundUseAbility")

    ---------------
    -- ABILITIES --
    ---------------

    net.Receive("TTT_SoulboundUseAbility", function(len, ply)
        local num = net.ReadUInt(4)
        if not ply:IsSoulbound() then return end

        local id = ply:GetNWString("TTTSoulboundAbility" .. tostring(num), "")
        if #id == 0 then return end

        local ability = SOULBOUND.Abilities[id]
        if not ability:Enabled() then return end
        if not ability:Condition() then return end

        local target = ply:GetObserverMode() ~= OBS_MODE_ROAMING and ply:GetObserverTarget() or nil
        ability:Use(ply, target)
    end)

    ----------------------
    -- ABILITY PURCHASE --
    ----------------------

    net.Receive("TTT_SoulboundBuyAbility", function(len, ply)
        local id = net.ReadString()
        if not ply:IsSoulbound() then return end

        local max = soulbound_max_abilities:GetInt()
        for i = 1, max do
            local slotId = ply:GetNWString("TTTSoulboundAbility" .. tostring(i), "")
            if #slotId > 0 then continue end

            ply:SetNWString("TTTSoulboundAbility" .. tostring(i), id)
            return
        end
        ply:PrintMessage(HUD_PRINTTALK, "You can't buy another ability!")
    end)

    -------------
    -- CLEANUP --
    -------------

    hook.Add("TTTPrepareRound", "Soulbound_TTTPrepareRound", function()
        for _, p in ipairs(player.GetAll()) do
            for i = 1, 9 do
                p:SetNWString("TTTSoulboundAbility" .. tostring(i), "")
            end
        end
    end)

    -----------------
    -- ALIVE CHECK --
    -----------------

    hook.Add("TTTPlayerSpawnForRound", "Soulbound_TTTPlayerSpawnForRound", function(ply, dead_only)
        if not IsPlayer(ply) then return end
        if ply:IsSoulbound() then
            for i = 1, 9 do
                ply:SetNWString("TTTSoulboundAbility" .. tostring(i), "")
            end
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

    local function CreateFavTable()
        if not sql.TableExists("ttt_soulbound_fav") then
            local query = "CREATE TABLE ttt_soulbound_fav (sid64 TEXT, ability_id TEXT)"
            sql.Query(query)
        end
    end

    local function AddFavorite(sid64, ability_id)
        local query = "INSERT INTO ttt_soulbound_fav VALUES('" .. sid64 .. "','" .. ability_id .. "')"
        sql.Query(query)
    end

    local function RemoveFavorite(sid64, ability_id)
        local query = "DELETE FROM ttt_soulbound_fav WHERE sid64 = '" .. sid64 .. "' AND `ability_id` = '" .. ability_id .. "'"
        sql.Query(query)
    end

    local function GetFavorites(sid64)
        local query = "SELECT ability_id FROM ttt_soulbound_fav WHERE sid64 = '" .. sid64 .. "'"
        local result = sql.Query(query)
        return result
    end

    local function IsFavorite(favorites, ability_id)
        for _, value in pairs(favorites) do
            local dbid = value["ability_id"]
            if (dbid == ability_id) then
                return true
            end
        end
        return false
    end

    local dshop
    local function OpenSoulboundShop()
        local maxAbilities = soulbound_max_abilities:GetInt()
        if maxAbilities == 0 then return end
        local ownedAbilities = {}
        for i = 1, maxAbilities do
            local slotId = client:GetNWString("TTTSoulboundAbility" .. tostring(i), "")
            if #slotId == 0 then break end
            table.insert(ownedAbilities, slotId)
        end

        local numCols = GetGlobalInt("ttt_bem_sv_cols", 4)
        local numRows = GetGlobalInt("ttt_bem_sv_rows", 5)
        local itemSize = GetGlobalInt("ttt_bem_sv_size", 64)

        if GetGlobalBool("ttt_bem_allow_change", true) then
            numCols = GetConVar("ttt_bem_cols"):GetInt()
            numRows = GetConVar("ttt_bem_rows"):GetInt()
            itemSize = GetConVar("ttt_bem_size"):GetInt()
        end

        -- margin
        local m = 5
        -- item list width
        local dlistw = ((itemSize + 2) * numCols) - 2 + 15
        local dlisth = ((itemSize + 2) * numRows) - 2 + 45
        -- right column width
        local diw = 270
        -- frame size
        local w = dlistw + diw + (m * 2)
        local h = dlisth + 75

        -- Close any existing traitor menu
        if IsValid(dshop) then dshop:Close() end

        local dframe = vgui.Create("DFrame")
        dframe:SetSize(w, h)
        dframe:Center()
        dframe:SetTitle(LANG.GetTranslation("abilities_title"))
        dframe:SetVisible(true)
        dframe:ShowCloseButton(true)
        dframe:SetMouseInputEnabled(true)
        dframe:SetDeleteOnClose(true)

        local dequip = vgui.Create("DPanel", dframe)
        dequip:SetPaintBackground(false)
        dequip:StretchToParent(m, m + 25, m, m)

        local dsearchheight = 25
        local dsearchpadding = 5
        local dsearch = vgui.Create("DTextEntry", dequip)
        dsearch:SetPos(0, 0)
        dsearch:SetSize(dlistw, dsearchheight)
        dsearch:SetPlaceholderText("Search...")
        dsearch:SetUpdateOnType(true)
        dsearch.OnGetFocus = function() dframe:SetKeyboardInputEnabled(true) end
        dsearch.OnLoseFocus = function() dframe:SetKeyboardInputEnabled(false) end

        --- Construct icon listing
        --- icon size = 64 x 64
        local dlist = vgui.Create("EquipSelect", dequip)
        -- local dlistw = 288
        dlist:SetPos(0, dsearchheight + dsearchpadding)
        dlist:SetSize(dlistw, dlisth + m)
        dlist:EnableVerticalScrollbar(true)
        dlist:EnableHorizontal(true)

        local bw, bh = 104, 25

        -- Whole right column
        local dih = h - bh - m - 4
        local dinfobg = vgui.Create("DPanel", dequip)
        dinfobg:SetPaintBackground(false)
        dinfobg:SetSize(diw, dih)
        dinfobg:SetPos(dlistw + m, 0)

        -- item info pane
        local dinfo = vgui.Create("ColoredBox", dinfobg)
        dinfo:SetColor(Color(90, 90, 95))
        dinfo:SetPos(0, 0)
        dinfo:StretchToParent(0, 0, m * 2, bh + (m * 2))

        local dfields = {}
        for _, k in pairs({ "Name", "Description" }) do
            dfields[k] = vgui.Create("DLabel", dinfo)
            dfields[k]:SetTooltip(LANG.GetTranslation("equip_spec_" .. k))
            dfields[k]:SetPos(m * 3, m * 2)
            dfields[k]:SetWidth(diw - m * 6)
        end

        dfields.Name:SetFont("TabLarge")

        dfields.Description:SetFont("DermaDefaultBold")
        dfields.Description:SetContentAlignment(7)
        dfields.Description:MoveBelow(dfields.Name, 1)

        local dhelp = vgui.Create("DPanel", dinfobg)
        dhelp:SetPaintBackground(false)
        dhelp:SetSize(diw, 64)
        dhelp:MoveBelow(dinfo, m)

        local function FillAbilityList(abilities)
            dlist:Clear()

            local paneltablefav = {}
            local paneltable = {}

            local ic = nil
            for _, ability in pairs(abilities) do
                if ability.Icon then
                    ic = vgui.Create("LayeredIcon", dlist)

                    ic.favorite = false
                    local favorites = GetFavorites(client:SteamID64())
                    if favorites then
                        if IsFavorite(favorites, ability.Id) then
                            ic.favorite = true
                            if GetConVar("ttt_bem_marker_fav"):GetBool() then
                                local star = vgui.Create("DImage")
                                star:SetImage("icon16/star.png")
                                star.PerformLayout = function(s)
                                    s:AlignTop(2)
                                    s:AlignRight(2)
                                    s:SetSize(12, 12)
                                end
                                star:SetTooltip("Favorite")
                                ic:AddLayer(star)
                                ic:EnableMousePassthrough(star)
                            end
                        end
                    end

                    ic:SetIconSize(itemSize)
                    ic:SetIcon(ability.Icon)
                else
                    ErrorNoHalt("Ability does not have model or material specified: " .. ability.Name .. "\n")
                end

                ic.ability = ability

                ic:SetTooltip(ability.Name)

                if #ownedAbilities >= maxAbilities or table.HasValue(ownedAbilities, ability.Id) then
                    ic:SetIconColor(Color(255, 255, 255, 80))
                end

                if ic.favorite then
                    table.insert(paneltablefav, ic)
                else
                    table.insert(paneltable, ic)
                end
            end

            local AddNameSortedItems = function(panels)
                if GetConVar("ttt_sort_alphabetically"):GetBool() then
                    table.sort(panels, function(a, b) return string.lower(a.ability.Name) < string.lower(b.ability.Name) end)
                end
                for _, panel in pairs(panels) do
                    dlist:AddPanel(panel)
                end
            end
            AddNameSortedItems(paneltablefav)
            if GetConVar("ttt_shop_random_position"):GetBool() then
                paneltable = table.Shuffle(paneltable)
                for _, panel in ipairs(paneltable) do
                    dlist:AddPanel(panel)
                end
            else
                AddNameSortedItems(paneltable)
            end

            dlist:SelectPanel(dlist:GetItems()[1])
        end

        local function DoesValueMatch(ability, data, value)
            local itemdata = ability[data]
            if isfunction(itemdata) then
                itemdata = itemdata()
            end
            return itemdata and string.find(string.lower(LANG.TryTranslation(itemdata)), string.lower(value), 1, true)
        end

        dsearch.OnValueChange = function(box, value)
            local filtered = {}
            for _, v in pairs(SOULBOUND.Abilities) do
                if v and (DoesValueMatch(v, "Name", value) or DoesValueMatch(v, "Description", value)) then
                    table.insert(filtered, v)
                end
            end
            FillAbilityList(filtered)
        end

        dhelp:SizeToContents()

        local dconfirm = vgui.Create("DButton", dinfobg)
        dconfirm:SetPos(0, dih - bh - m)
        dconfirm:SetSize(bw, bh)
        dconfirm:SetDisabled(true)
        dconfirm:SetText(LANG.GetTranslation("abilities_confirm"))

        dlist.OnActivePanelChanged = function(self, _, new)
            if new and new.ability then
                for k, v in pairs(new.ability) do
                    if dfields[k] then
                        local value = v
                        if type(v) == "function" then
                            value = v()
                        end
                        dfields[k]:SetText(LANG.TryTranslation(value))
                        dfields[k]:SetAutoStretchVertical(true)
                        dfields[k]:SetWrap(true)
                    end
                end
                if #ownedAbilities >= maxAbilities or table.HasValue(ownedAbilities, new.ability.Id) then
                    dconfirm:SetDisabled(true)
                else
                    dconfirm:SetDisabled(false)
                end
            end
        end

        dconfirm.DoClick = function()
            local pnl = dlist.SelectedPanel
            if not pnl or not pnl.ability then return end
            local choice = pnl.ability
            net.Start("TTT_SoulboundBuyAbility")
            net.WriteString(choice.Id)
            net.SendToServer()
            dframe:Close()
        end

        local dfav = vgui.Create("DButton", dinfobg)
        dfav:MoveRightOf(dconfirm)
        local bx, _ = dfav:GetPos()
        dfav:SetPos(bx + 1, dih - bh - m)
        dfav:SetSize(bh, bh)
        dfav:SetDisabled(false)
        dfav:SetText("")
        dfav:SetImage("icon16/star.png")
        dfav:SetTooltip(LANG.GetTranslation("buy_favorite_toggle"))
        dfav.DoClick = function()
            local sid64 = client:SteamID64()
            local pnl = dlist.SelectedPanel
            if not pnl or not pnl.ability then return end
            local choice = pnl.ability
            local id = choice.Id
            CreateFavTable()
            if pnl.favorite then
                RemoveFavorite(sid64, id)
            else
                AddFavorite(sid64, id)
            end

            dsearch:OnTextChanged()
        end

        local drdm = vgui.Create("DButton", dinfobg)
        drdm:MoveRightOf(dfav)
        bx, _ = drdm:GetPos()
        drdm:SetPos(bx + 1, dih - bh - m)
        drdm:SetSize(bh, bh)
        drdm:SetDisabled(false)
        drdm:SetText("")
        drdm:SetImage("icon16/basket_go.png")
        drdm:SetTooltip(LANG.GetTranslation("abilities_random"))
        drdm.DoClick = function()
            local ability_panels = dlist:GetItems()
            local buyable_abilities = {}
            for _, panel in pairs(ability_panels) do
                if panel.ability and #ownedAbilities < maxAbilities and not table.HasValue(ownedAbilities, panel.ability.Id) then
                    table.insert(buyable_abilities, panel)
                end
            end

            if #buyable_abilities == 0 then return end

            local random_panel = buyable_abilities[math.random(1, #buyable_abilities)]
            dlist:SelectPanel(random_panel)
            dconfirm.DoClick()
        end

        local dcancel = vgui.Create("DButton", dinfobg)
        dcancel:MoveRightOf(drdm)
        bx, _ = dcancel:GetPos()
        dcancel:SetPos(bx + 1, dih - bh - m)
        dcancel:SetSize(bw, bh)
        dcancel:SetDisabled(false)
        dcancel:SetText(LANG.GetTranslation("close"))
        dcancel.DoClick = function() dframe:Close() end

        FillAbilityList(SOULBOUND.Abilities)

        dframe:MakePopup()
        dframe:SetKeyboardInputEnabled(false)

        dshop = dframe
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

    local function UseAbility(num)
        if num > soulbound_max_abilities:GetInt() then return end
        net.Start("TTT_SoulboundUseAbility")
        net.WriteUInt(num, 4)
        net.SendToServer()
    end

    hook.Add("PlayerBindPress", "Soulbound_PlayerBindPress", function(ply, bind, pressed)
        if not IsPlayer(ply) then return end
        if not ply:IsSoulbound() then return end
        if not pressed then return end

        if string.sub(bind, 1, 4) == "slot" then
            local num = tonumber(string.sub(bind, 5, -1)) or 1
            UseAbility(num)
        end
    end)

    ---------
    -- HUD --
    ---------

    hook.Add("HUDPaint", "Soulbound_HUDPaint", function()
        if GetRoundState() ~= ROUND_ACTIVE then return end

        if not client then
            client = LocalPlayer()
        end
        if not client:IsSoulbound() then return end

        local max_abilities = soulbound_max_abilities:GetInt()
        if max_abilities == 0 then return end

        local margin = 2
        local width = 300
        local titleHeight = 28
        local bodyHeight = titleHeight * 2 + margin
        local x = ScrW() - width - 20
        local y = ScrH() - 20 + margin

        for i = max_abilities, 1, -1 do
            local id = client:GetNWString("TTTSoulboundAbility" .. tostring(i), "")
            local ability = SOULBOUND.Abilities[id]
            if #id == 0 or not ability then
                y = y - titleHeight - margin
                draw.RoundedBox(8, x, y, width, titleHeight, Color(20, 20, 20, 200))
                draw.RoundedBoxEx(8, x, y, titleHeight, titleHeight, ROLE_COLORS[ROLE_SOULBOUND], true, false, true, false)
                draw.SimpleText("Unbound", "TimeLeft", x + titleHeight + (margin * 2), y + (titleHeight / 2), COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            else
                y = y - titleHeight - bodyHeight - (margin * 2)
                draw.RoundedBox(8, x, y, width, titleHeight + bodyHeight + margin, Color(20, 20, 20, 200))
                draw.RoundedBoxEx(8, x, y, titleHeight, titleHeight, ROLE_COLORS[ROLE_SOULBOUND], true, false, false, true)
                draw.SimpleText(ability.Name, "TimeLeft", x + titleHeight + (margin * 2), y + (titleHeight / 2), COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                ability:DrawHUD(x, y + titleHeight + margin, width, bodyHeight)
            end
            CRHUD:ShadowedText(tostring(i), "Trebuchet22", x + (titleHeight / 2), y + (titleHeight / 2), COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end)

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