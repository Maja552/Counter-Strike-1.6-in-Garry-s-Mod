
-- First spawn
function SUBGAMEMODE:OnPlayerInitialSpawn(ply)
    ply.nextDamageZSound = 0
    ply.nextRandomZSound = 0
    ply.nextZFireSound = 0
    ply.zombie_lives = 0
    ply.zombie_madness_til = 0
    ply.nextBeam = 0
    ply.WasZombie = 0
    ply.no_idle_sounds = false
    ply.barricades_places = 0
    ply.is_radioactive = false
    ply.next_radioactive_attack = 0
    return GAMEMODE:DEFAULT_OnPlayerInitialSpawn(ply)
end

-- Player set human (basically spawns and resets the player)
function SUBGAMEMODE:PlayerSetHuman(ply)
    return GAMEMODE:DEFAULT_PlayerSetHuman(ply)
end

function SUBGAMEMODE:PlayerSpawn(ply)
	if ply:IsSpectator() then return end
	if ply:Team() == TEAM_UNASSIGNED then
		ply:SetSpectator()
		ply:SetNoCollideWithTeammates(true)
		return
	end

	ply:SetHuman()
	--ZMTEST player_manager.OnPlayerSpawn(ply, false)
	--ZMTEST player_manager.RunClass(ply, "Spawn")
	ply:AfterSetHuman()
end

print("Gamemode loaded gamemodes/zombie_mod/sv_player_spawn.lua")