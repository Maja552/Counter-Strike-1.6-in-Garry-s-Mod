
function SUBGAMEMODE:Post_Preparing()
    for k,v in pairs(player.GetAll()) do
        if v:Team() == TEAM_UNASSIGNED or (v.NextSpawnTime and v.NextSpawnTime > CurTime()) then
            v:SetTeam(TEAM_SPECTATOR)
            v:Spawn()
        end
    end

	GAMEMODE:DEFAULT_Assign_Players()

    local all_plys = GAMEMODE:GetPlayers()

    -- Spawn all players, resets their things and sets the model
    for k,v in pairs(all_plys) do
        v:Spawn()
    end

    local team_tab = {}

    -- Give loadout weapons, money
    for k,v in pairs(all_plys) do
        local team_assign_func = self.CONFIG.ASSIGN_TEAMS[v:Team()]
        if team_assign_func then
            team_assign_func(v)
        end

        hook.Call("PlayerStripLoadout", GAMEMODE, v)
        hook.Call("PlayerLoadout", GAMEMODE, v)

        table.ForceInsert(team_tab, {v, v:CS16Team()})
    end

    -- Update the cs16_team of all players
    net.Start("cs16_updateallteams")
        net.WriteTable(team_tab)
    net.Broadcast()

    RunConsoleCommand("sv_accelerate", "8")
end

print("Gamemode loaded gamemodes/paintball/sv_round.lua")