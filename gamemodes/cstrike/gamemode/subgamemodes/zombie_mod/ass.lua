--[[---------------------------------------------------------
	Name: gamemode:DoPlayerDeath( )
	Desc: Carries out actions when the player dies
-----------------------------------------------------------]]
function GM:DoPlayerDeath( ply, attacker, dmginfo )

	ply:CreateRagdoll()

	ply:AddDeaths( 1 )

	if ( attacker:IsValid() && attacker:IsPlayer() ) then

		if ( attacker == ply ) then
			attacker:AddFrags( -1 )
		else
			attacker:AddFrags( 1 )
		end

	end

end






--[[---------------------------------------------------------
	Name: gamemode:PlayerDeathThink( player )
	Desc: Called when the player is waiting to respawn
-----------------------------------------------------------]]
function GM:PlayerDeathThink( pl )

	if ( pl.NextSpawnTime && pl.NextSpawnTime > CurTime() ) then return end

	if ( pl:IsBot() || pl:KeyPressed( IN_ATTACK ) || pl:KeyPressed( IN_ATTACK2 ) || pl:KeyPressed( IN_JUMP ) ) then

		pl:Spawn()

	end

end







--[[---------------------------------------------------------
	Name: gamemode:PlayerDeath()
	Desc: Called when a player dies.
-----------------------------------------------------------]]
function GM:PlayerDeath( ply, inflictor, attacker )

	-- Don't spawn for at least 2 seconds
	ply.NextSpawnTime = CurTime() + 2
	ply.DeathTime = CurTime()

	if ( IsValid( attacker ) && attacker:GetClass() == "trigger_hurt" ) then attacker = ply end

	if ( IsValid( attacker ) && attacker:IsVehicle() && IsValid( attacker:GetDriver() ) ) then
		attacker = attacker:GetDriver()
	end

	if ( !IsValid( inflictor ) && IsValid( attacker ) ) then
		inflictor = attacker
	end

	-- Convert the inflictor to the weapon that they're holding if we can.
	-- This can be right or wrong with NPCs since combine can be holding a
	-- pistol but kill you by hitting you with their arm.
	if ( IsValid( inflictor ) && inflictor == attacker && ( inflictor:IsPlayer() || inflictor:IsNPC() ) ) then

		inflictor = inflictor:GetActiveWeapon()
		if ( !IsValid( inflictor ) ) then inflictor = attacker end

	end

	player_manager.RunClass( ply, "Death", inflictor, attacker )

	if ( attacker == ply ) then

		net.Start( "PlayerKilledSelf" )
			net.WriteEntity( ply )
		net.Broadcast()

		MsgAll( attacker:Nick() .. " suicided!\n" )

	return end

	if ( attacker:IsPlayer() ) then

		net.Start( "PlayerKilledByPlayer" )

			net.WriteEntity( ply )
			net.WriteString( inflictor:GetClass() )
			net.WriteEntity( attacker )

		net.Broadcast()

		MsgAll( attacker:Nick() .. " killed " .. ply:Nick() .. " using " .. inflictor:GetClass() .. "\n" )

	return end

	net.Start( "PlayerKilled" )

		net.WriteEntity( ply )
		net.WriteString( inflictor:GetClass() )
		net.WriteString( attacker:GetClass() )

	net.Broadcast()

	MsgAll( ply:Nick() .. " was killed by " .. attacker:GetClass() .. "\n" )

end






--[[---------------------------------------------------------
	Name: gamemode:PlayerSpawnAsSpectator()
	Desc: Player spawns as a spectator
-----------------------------------------------------------]]
function GM:PlayerSpawnAsSpectator( pl )

	pl:StripWeapons()

	if ( pl:Team() == TEAM_UNASSIGNED ) then

		pl:Spectate( OBS_MODE_FIXED )
		return

	end

	pl:SetTeam( TEAM_SPECTATOR )
	pl:Spectate( OBS_MODE_ROAMING )

end







--[[---------------------------------------------------------
	Name: gamemode:PlayerSpawn()
	Desc: Called when a player spawns
-----------------------------------------------------------]]
function GM:PlayerSpawn( pl, transiton )

	--
	-- If the player doesn't have a team in a TeamBased game
	-- then spawn him as a spectator
	--
	if ( self.TeamBased && ( pl:Team() == TEAM_SPECTATOR || pl:Team() == TEAM_UNASSIGNED ) ) then

		self:PlayerSpawnAsSpectator( pl )
		return

	end

	-- Stop observer mode
	pl:UnSpectate()

	pl:SetupHands()

	player_manager.OnPlayerSpawn( pl, transiton )
	player_manager.RunClass( pl, "Spawn" )

	-- If we are in transition, do not touch player's weapons
	if ( !transiton ) then
		-- Call item loadout function
		hook.Call( "PlayerLoadout", GAMEMODE, pl )
	end

	-- Set player model
	hook.Call( "PlayerSetModel", GAMEMODE, pl )

end