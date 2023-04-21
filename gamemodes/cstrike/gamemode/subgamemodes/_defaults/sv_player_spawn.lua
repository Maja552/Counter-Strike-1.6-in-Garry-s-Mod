
function GM:DEFAULT_OnPlayerInitialSpawn(ply)
	ply.cs16_money = SUBGAMEMODE.CONFIG.STARTING_MONEY
	GAMEMODE:UpdateAllMoney()
end

function GM:DEFAULT_PlayerSpawn(ply)
	if ply:IsSpectator() then return end
	if ply:Team() == TEAM_UNASSIGNED then
		ply:SetSpectator()
		ply:SetNoCollideWithTeammates(true)
		return
	end

	ply:SetHuman()
	player_manager.OnPlayerSpawn(ply, false)
	player_manager.RunClass(ply, "Spawn")
	ply:AfterSetHuman()
end

print("Gamemode loaded gamemodes/_defaults/sv_player_spawn.lua")