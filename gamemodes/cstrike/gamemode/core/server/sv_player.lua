
function GM:GetPlayers()
	local plys = {}
	for k,v in pairs(player.GetAll()) do
		local team = v:CS16Team()
		--if team != TEAM_UNASSIGNED and team != TEAM_SPECTATOR then
		if team != TEAM_SPECTATOR then
			table.ForceInsert(plys, v)
		end
	end
	return plys
end

hook.Add("PlayerUse", "use_sound_sv", function(ply, ent)
	local using = ply:KeyDown(IN_USE)
	if ply.clicked_use then
		if !using then
			ply.clicked_use = false
		end
	elseif using then
		net.Start("cs16_usesound")
		net.Send(ply)
		ply.clicked_use = true
	end
end)

function GM:PlayerSetHandsModel(ply, ent)
	local simplemodel = player_manager.TranslateToPlayerModelName(ply:GetModel())
	local info = player_manager.TranslatePlayerHands(simplemodel)
	if info then
		ent:SetModel(info.model)
		ent:SetSkin(info.skin)
		ent:SetBodyGroups(info.body)
	end
end

function GM:PlayerInitialSpawn(ply)
    ply.maxJumpVel = 0
    ply.jumpPenaltyUntil = 0
    ply.jumpPenaltyStage = 0
    ply.jumpPenaltyMaxSpeed = SUBGAMEMODE.CONFIG.DEFAULT_WALK_SPEED
    ply.jumpPenaltyMinSpeed = 5
	ply.jumped = nil
	ply.changed_team = false
	ply.has_bought_armor = false
	ply.has_bought_armor_full = false
	ply.nextSprayer = 0
	ply.nextRadioSound = 0
	ply.purchase_notif_fired = false
	ply.spect_notif_fired = false
	ply.clicked_use = false
	ply.cloaked_til = 0
	ply.frozen_for = 0
	ply.frozen = false
	ply.speed_limit_enabled = true
	ply.slow_down = 0
	ply.ArmingC4 = 0
	ply.WantToPlay = true
	ply.cs_playermodels = {}
	ply:SetCS16Team(TEAM_SPECTATOR, false)
	SUBGAMEMODE:OnPlayerInitialSpawn(ply)
	ply:SetNoDraw(true)
	ply:SetTeam(TEAM_UNASSIGNED)

	local rnd_spawn_point = self:GetRandomSpawnPoint()
	if IsValid(rnd_spawn_point) then
		ply:SetPos(rnd_spawn_point:GetPos())
	end

	if ply:IsBot() then
		local all_ts = {}
		local all_cts = {}
	
		for k,v in pairs(GAMEMODE:GetPlayers()) do
			if v != ply then
				if v:CS16Team() == TEAM_T then
					table.ForceInsert(all_ts, v)
	
				elseif v:CS16Team() == TEAM_CT then
					table.ForceInsert(all_cts, v)
				end
			end
		end

		if #all_ts >= #all_cts then
			ply:SetCS16Team(TEAM_CT, true)
		else
			ply:SetCS16Team(TEAM_T, true)
		end
	else
		ply:SendLua("firststartmenu = true CreateStartMenu()")
	end
end

function GM:PlayerSpawn(ply)
	return SUBGAMEMODE:PlayerSpawn(ply)
end

function GM:PlayerSetSpeeds(ply)
    ply.speed_walking = SUBGAMEMODE.CONFIG.DEFAULT_WALK_SPEED
	ply:SetWalkSpeed(ply.speed_walking)
    ply:SetRunSpeed(ply.speed_walking)
	ply:SetCrouchedWalkSpeed(0.37)
	
	ply.jump_power = SUBGAMEMODE.CONFIG.DEFAULT_JUMP_POWER
	ply:SetJumpPower(ply.jump_power)
    ply:SetLadderClimbSpeed(150)
end

function GM:PlayerSetModel(ply)
    local pl_team = ply:Team()

    if ply.cs_playermodels and ply.cs_playermodels[pl_team] then
        ply:SetModel(ply.cs_playermodels[pl_team])
    else
        local team_playermodels = SUBGAMEMODE.CONFIG.PLAYERMODELS[pl_team]
        if !team_playermodels then
            team_playermodels = SUBGAMEMODE.CONFIG.PLAYERMODELS[math.random(1,2)]
		end
		if team_playermodels then
			ply:SetModel(team_playermodels[math.random(#team_playermodels)])
			ply.cs_playermodels[pl_team] = ply:GetModel()
		end
	end
	ply:SetBodyGroups("000")
end

function GM:PlayerStripLoadout(ply)
    ply:StripWeapons()
    ply:RemoveAllAmmo()
end

function GM:PlayerLoadout(ply)
	return SUBGAMEMODE:PlayerLoadout(ply)
end

include("sv_spawnpoints.lua")

function HandlePlayerSpeeds()
	if !GM_INITIALIZED then return end
	for k,v in pairs(player.GetAll()) do
		if v:Alive() and !v:IsSpectator() and !v:IsFrozen() then
			local new_walk_speed, new_jump_power = v:CalculateSpeeds()
			if !new_walk_speed or !new_jump_power then continue end

			--FINISHED CHANGING SPEEDS
			if v.speed_limit_enabled then
				new_walk_speed = math.Clamp(math.floor(new_walk_speed), 1, SUBGAMEMODE.CONFIG.DEFAULT_WALK_SPEED)
				new_jump_power = math.Clamp(math.floor(new_jump_power), 1, SUBGAMEMODE.CONFIG.DEFAULT_JUMP_POWER)
			end

			--v:PrintMessage(HUD_PRINTCENTER, new_walk_speed .. "    " .. new_jump_power)

			v:SetWalkSpeed(new_walk_speed)
			v:SetRunSpeed(new_walk_speed)
			v:SetJumpPower(new_jump_power)
		end
	end
	next_speed_handling = CurTime() + 0.1
end
hook.Add("Tick", "CS16_PlayerSpeeds", HandlePlayerSpeeds)

function GM:CanPlayerSuicide(ply)
	return SUBGAMEMODE:CanPlayerSuicide(ply)
end

function GM:PlayerCanPickupWeapon(ply, weapon)
	return SUBGAMEMODE:PlayerCanPickupWeapon(ply, weapon)
end

function GM:AllowPlayerPickup(ply, ent)
	return SUBGAMEMODE:AllowPlayerPickup(ply, ent)
end

function GM:DoPlayerDeath(ply, attacker, dmginfo)
	SUBGAMEMODE:DoPlayerDeath(ply, attacker, dmginfo)
end

function GM:PostPlayerDeath(ply)
	SUBGAMEMODE:PostPlayerDeath(ply)
end

function GM:PlayerDeath(ply, inflictor, attacker)
	SUBGAMEMODE:PlayerDeath(ply, inflictor, attacker)
end

function GM:PlayerDeathThink(ply)
	--SUBGAMEMODE:PlayerDeathThink(ply)
end

hook.Add("Tick", "NewDeathThink", function()
	for k, ply in pairs(player.GetAll()) do
		if !ply:Alive() then
			SUBGAMEMODE:PlayerDeathThink(ply)
		end
	end
end)

print("Gamemode loaded sv_player.lua")