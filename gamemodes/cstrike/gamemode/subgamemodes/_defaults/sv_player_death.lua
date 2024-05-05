
function GM:DEFAULT_DoCorpseDeathSound(ply, corpse)
	corpse:EmitSound("cstrike/player/die"..math.random(1,3)..".wav")
end

function GM:DEFAULT_PlayerDeathSound(ply)
	--ply:EmitSound("cstrike/player/die"..math.random(1,3)..".wav")
	return true
 end

function GM:DEFAULT_DoPlayerDeath(ply, attacker, dmginfo)
	ply:AddDeaths(1)
	if attacker:IsValid() and attacker:IsPlayer() then
		if attacker == ply or ply:Team() == attacker:Team() then
			attacker:AddFrags(-1)
			attacker:AddMoney(-3300, true)
		else
			attacker:AddFrags(1)
			attacker:AddMoney(300, true)
		end
	end
	
	ply:DropAllWeapons()
end

function GM:DEFAULT_PlayerDeathThink(ply)
	if ply.NextSpawnTime and ply.NextSpawnTime > CurTime() then return end

	if ply:IsBot() or ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_ATTACK2) or ply:KeyPressed(IN_JUMP) then
		ply:Spawn()
	end
end

function GM:DEFAULT_MakePlayerRagdoll(ply)
	local corpse_velocity_multiplier = 1.5

	if(IsValid(ply:GetRagdollEntity())) then
		ply:GetRagdollEntity():Remove()
	end

	local rag = ents.Create("prop_ragdoll")
	rag:SetPos(ply:GetPos())
	rag:SetModel(ply:GetModel())
	rag:SetAngles(ply:GetAngles())
	rag:Spawn()
	rag:Activate()
	rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	timer.Simple(1, function() if IsValid(rag) then rag:CollisionRulesChanged() end end)
	
	local num = rag:GetPhysicsObjectCount() - 1
	local v = ply:GetVelocity() * 0.35
	
	for i=0, num do
		local bone = rag:GetPhysicsObjectNum(i)
		if IsValid(bone) then
			local bp, ba = ply:GetBonePosition(rag:TranslatePhysBoneToBone(i))
			if bp and ba then
				bone:SetPos(bp)
				bone:SetAngles(ba)
			end
			bone:SetVelocity(v * corpse_velocity_multiplier)
		end
	end

	return rag
end

function GM:DEFAULT_PostPlayerDeath(ply)
	local rag = SUBGAMEMODE:MakePlayerRagdoll(ply)
	SUBGAMEMODE:DoCorpseDeathSound(ply, rag)

    ply:SetTeam(TEAM_UNASSIGNED)
	ply:Spawn()
end

function GM:DEFAULT_PlayerDeath(ply, inflictor, attacker)
	-- Don't spawn for at least 2 seconds
	ply.NextSpawnTime = CurTime() + 2
    ply.DeathTime = CurTime()

	if IsValid(attacker) and attacker:GetClass() == "trigger_hurt" then attacker = ply end

	if IsValid(attacker) and attacker:IsVehicle() and IsValid(attacker:GetDriver()) then
		attacker = attacker:GetDriver()
	end

	if (!IsValid(inflictor) and IsValid(attacker)) then
		inflictor = attacker
	end

	-- Convert the inflictor to the weapon that they're holding if we can.
	-- This can be right or wrong with NPCs since combine can be holding a
	-- pistol but kill you by hitting you with their arm.
	if (IsValid(inflictor) and inflictor == attacker and (inflictor:IsPlayer() or inflictor:IsNPC())) then
		inflictor = inflictor:GetActiveWeapon()
		if !IsValid(inflictor) then inflictor = attacker end
	end

	player_manager.RunClass(ply, "Death", inflictor, attacker)

	if (attacker == ply) then
		net.Start("PlayerKilledSelf")
			net.WriteEntity(ply)
		net.Broadcast()
        return
    end

	if attacker:IsPlayer() then
		net.Start("PlayerKilledByPlayer")

			net.WriteEntity(ply)
			net.WriteString(inflictor:GetClass())
			net.WriteEntity(attacker)

		net.Broadcast()

		print(attacker:Nick() .. " killed " .. ply:Nick() .. " using " .. inflictor:GetClass())
        return
    end

	net.Start("PlayerKilled")
		net.WriteEntity(ply)
		net.WriteString(inflictor:GetClass())
		net.WriteString(attacker:GetClass())
	net.Broadcast()

	print(ply:Nick() .. " was killed by " .. attacker:GetClass() .. "\n")
end

print("Gamemode loaded gamemodes/_defaults/sv_player_death.lua")