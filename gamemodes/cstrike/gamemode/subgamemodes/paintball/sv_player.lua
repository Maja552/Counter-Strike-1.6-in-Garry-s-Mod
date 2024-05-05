
function SUBGAMEMODE:PlayerLoadout(ply)
	ply:Give("weapon_cs16_knife")
	if ply:Team() == TEAM_T then
		ply:Give("weapon_cs16_pb_glock18")

	elseif ply:Team() == TEAM_CT then
		ply:Give("weapon_cs16_pb_usp")
	end

    ply:Give("weapon_cs16_pb_tmp")
    ply:Give("weapon_cs16_pb_mp5")
    ply:Give("weapon_cs16_pb_nade")
	
    ply:GiveAmmo(200, "CS16_PBAMMO", false)

	return true
end

-- Player set human (basically spawns and resets the player)
function SUBGAMEMODE:PlayerSetHuman(ply)
	ply:SetNWBool("CanPlantBomb", false)
	ply.BombZone = nil
	ply.InBombZone = 0
	ply.ArmingC4 = 0

	ply.frozen_for = 0
	ply.frozen = false
	ply.speed_limit_enabled = true

	hook.Call("PlayerSetSpeeds", GAMEMODE, ply)

	ply:ResetHull()
	ply:SetMaterial("")
	ply:SetColor(Color(255,255,255,255))

    ply:SetBloodColor(BLOOD_COLOR_ANTLION_WORKER) -- goofy blood

	ply:SetNoDraw(false)
	ply:SetNoCollideWithTeammates(false)
	ply:SetNWBool("HasHelmet", false)
	
	ply:UnSpectate()

	ply:SetHealth(100)
    ply:SetMaxHealth(100)
end

print("Gamemode loaded gamemodes/paintball/sv_player.lua")