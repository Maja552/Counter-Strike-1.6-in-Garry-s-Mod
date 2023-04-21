
CS16_BombExploded = false

function GM:DEFAULT_WinCheck()
    if CS16_BombExploded then return TEAM_T, WIN_BOMB end

    local all_ts_a = 0
    local all_cts_a = 0
    for k,v in pairs(player.GetAll()) do
        if !v:Alive() or v:IsSpectator() then continue end

        if v:Team() == TEAM_T then
            all_ts_a = all_ts_a + 1

        elseif v:Team() == TEAM_CT then
            all_cts_a = all_cts_a + 1
        end
    end
    if all_ts_a == 0 and all_cts_a == 0 then
        return WIN_DRAW, WIN_DRAW

    elseif all_ts_a > 0 and all_cts_a == 0 then
        return TEAM_T, WIN_ELIMINATION

    elseif all_cts_a > 0 and all_ts_a == 0 then
        return TEAM_CT, WIN_ELIMINATION
    end
    return 0
end

util.AddNetworkString("cs16_postroundstart")
function GM:DEFAULT_Post_PostRoundStart(win_id, win_reason)
    net.Start("cs16_postroundstart")
        net.WriteInt(win_id, 8)
    net.Broadcast()

    if win_reason == WIN_TIME then
        SUBGAMEMODE.CONFIG.CS16_WinRewards.time(win_id, win_reason)

    elseif win_reason == WIN_ELIMINATION then
        SUBGAMEMODE.CONFIG.CS16_WinRewards.elimination(win_id, win_reason)

    elseif win_reason == WIN_BOMB then
        SUBGAMEMODE.CONFIG.CS16_WinRewards.bomb(win_id, win_reason)
    end

    SUBGAMEMODE.CONFIG.CS16_LostRewards(win_id, win_reason)
end

util.AddNetworkString("cs16_roundstart")
function GM:DEFAULT_Post_RoundStart()
	net.Start("cs16_roundstart")
	net.Broadcast()
end

function GM:DEFAULT_Assign_Players()
    for i,v in ipairs(player.GetAll()) do
        if v:CS16Team() == TEAM_T then
            v:SetTeam(TEAM_T)
            
        elseif v:CS16Team() == TEAM_CT then
            v:SetTeam(TEAM_CT)
        end
    end
end

function GM:DEFAULT_Post_Preparing()
    for k,v in pairs(player.GetAll()) do
        if v:Team() == TEAM_UNASSIGNED or (v.NextSpawnTime and v.NextSpawnTime > CurTime()) then
            v:SetTeam(TEAM_SPECTATOR)
            v:Spawn()
        end
    end

	self:DEFAULT_Assign_Players()

    CS16_BombExploded = false

    local all_plys = GAMEMODE:GetPlayers()

    -- Spawn all players, resets their things and sets the model
    for k,v in pairs(all_plys) do
        v:Spawn()
    end

    local team_tab = {}

    -- Give loadout weapons, money
    for k,v in pairs(all_plys) do
        local team_assign_func = self.DEFAULT_CONFIG.ASSIGN_TEAMS[v:Team()]
        if team_assign_func then
            team_assign_func(v)
        end
        if v.changed_team or #v:GetWeapons() == 0 then
            hook.Call("PlayerStripLoadout", GAMEMODE, v)
            hook.Call("PlayerLoadout", GAMEMODE, v)
        end

        table.ForceInsert(team_tab, {v, v:CS16Team()})
    end

    -- Update the cs16_team of all players
    net.Start("cs16_updateallteams")
        net.WriteTable(team_tab)
    net.Broadcast()

    -- Sends the money information to all clients
    GAMEMODE:UpdateAllMoney()

    RunConsoleCommand("sv_accelerate", "8")

    -- So terrorists dont have two c4s
    for k,v in pairs(team.GetPlayers(TEAM_T)) do
        if v:HasWeapon("weapon_cs16_c4") then
            v:StripWeapon("weapon_cs16_c4")
            v:ConCommand("lastinv")
        end
    end

    -- Gives the C4 to a random terrorist
    local c4_person = team.GetPlayers(TEAM_T)[math.random(#team.GetPlayers(TEAM_T))]
    if IsValid(c4_person) then
        local c4 = c4_person:Give("weapon_cs16_c4")
        if IsValid(c4) then
            c4:SetClip1(1)
            c4_person:SetBodygroup(1, 1)
        end
    end
end

print("Gamemode loaded gamemodes/_defaults/sv_round.lua")