local twins_enabled = CreateConVar("ttt_twins_enabled", "0", FCVAR_REPLICATED)
local twins_invulnerability_timer = CreateConVar("ttt_twins_invulnerability_timer", "20", FCVAR_REPLICATED)

-- TODO: Figure out how to get ULX to work cleanly with the new ConVars (And potentially hide some of the old ones)

if SERVER then
    local twins_chance = CreateConVar("ttt_twins_chance", "0.1", FCVAR_REPLICATED)
    local twins_min_players = CreateConVar("ttt_twins_min_players", "0", FCVAR_REPLICATED)

    --------------------
    -- ROLE SELECTION --
    --------------------

    hook.Add("TTTSelectRoles", "Twins_TTTSelectRoles", function()
        if not twins_enabled:GetBool() then return end
        if math.random() > twins_chance:GetFloat() then return end

        local players = {}
        local choices = {}

        for _, v in ipairs(player.GetAll()) do
            if IsValid(v) then
                if not v:IsSpec() then
                    table.insert(players, v)
                    if v:GetRole() == ROLE_NONE then
                        table.insert(choices, v)
                    end
                end
            end
        end

        if twins_min_players:GetInt() ~= 0 and #players < twins_min_players:GetInt() then return end

        if CRULX and CRULX.PlysMarkedForNextRound then -- TODO: Actually make this table globally accessible
            for k, _ in pairs(CRULX.PlysMarkedForNextRound) do
                local ply = player.GetBySteamID64(k)
                if table.HasValue(choices, ply) then
                    table.RemoveByValue(choices, ply)
                end
            end
        end

        if #choices < 2 then return end

        table.Shuffle(choices)

        choices[1]:SetRole(ROLE_GOODTWIN)
        choices[2]:SetRole(ROLE_EVILTWIN)
    end)

    ------------------
    -- ANNOUNCEMENT --
    ------------------

    hook.Add("TTTBeginRound", "Twins_TTTBeginRound", function()
        local goodTwin = nil
        local evilTwin = nil
        for _, v in ipairs(player.GetAll()) do
            if v:IsGoodTwin() then
                if goodTwin ~= nil then return end
                goodTwin = v
            elseif v:IsEvilTwin() then
                if evilTwin ~= nil then return end
                evilTwin = v
            end
        end

        goodTwin:QueueMessage(MSG_PRINTBOTH, evilTwin:Nick() .. " is your " .. ROLE_STRINGS[ROLE_EVILTWIN] .. ".")
        evilTwin:QueueMessage(MSG_PRINTBOTH, goodTwin:Nick() .. " is your " .. ROLE_STRINGS[ROLE_GOODTWIN] .. ".")
    end)

    -- TODO: Prevent twins from being able to damage each other until they are the last two non-jesters
    -- TODO: Grant invulnerability to a twin when they are the last twin standing
end