
function GM:DEFAULT_OnPlayerInitialSpawn(ply)
	ply.cs16_money = SUBGAMEMODE.CONFIG.STARTING_MONEY
	GAMEMODE:UpdateAllMoney()
end

function GM:DEFAULT_PlayerSetHuman(ply)
	ply:SetNWBool("CanBuy", false)
	ply.BuyZone = nil
	ply.InBuyZone = 0

	ply:SetNWBool("CanPlantBomb", false)
	ply.BombZone = nil
	ply.InBombZone = 0
	ply.ArmingC4 = 0

	ply.frozen_for = 0
	ply.frozen = false
	ply.speed_limit_enabled = true

	hook.Call("PlayerSetSpeeds", GAMEMODE, ply)

	ply:ResetHull()
	--ply:SetHull(Vector(-16, -16, 0), Vector(16, 16, 72))
	--ply:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 36))
	ply:SetMaterial("")
	ply:SetColor(Color(255,255,255,255))
    ply:SetBloodColor(BLOOD_COLOR_RED)
	ply:SetNoDraw(false)
	ply:SetNoCollideWithTeammates(false)
	ply:SetNWBool("HasHelmet", false)
	
	ply:UnSpectate()

	ply:SetHealth(100)
    ply:SetMaxHealth(100)
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

function GM:DEFAULT_PlayerLoadout(ply)
	ply:Give("weapon_cs16_knife")
	if ply:Team() == TEAM_T then
		ply:Give("weapon_cs16_glock18")
		ply:GiveAmmo(40, "CS16_9MM", false)

	elseif ply:Team() == TEAM_CT then
		ply:Give("weapon_cs16_usp")
		ply:GiveAmmo(24, "CS16_45ACP", false)
	end

	return true
end

print("Gamemode loaded gamemodes/_defaults/sv_player_spawn.lua")