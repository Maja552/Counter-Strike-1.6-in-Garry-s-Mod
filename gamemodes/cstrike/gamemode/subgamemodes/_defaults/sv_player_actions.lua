
function GM:DEFAULT_DropCurrentWeapon(ply)
	if game_state == GAMESTATE_PREPARING and SUBGAMEMODE.CONFIG.PREPARING_FREEZE then return end
	if !ply:IsSpectator() and ply:Alive() then
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) then
			local candrop = true
			if isfunction(wep.CanDrop) then
				candrop = wep:CanDrop()
			end
			if candrop then
				ply:DropWep(wep)
				ply:ConCommand("lastinv")
			else
				ply:OldPrintMessage("This weapon cannot be dropped")
			end
		end
	end
end

function GM:DEFAULT_ModelChange(ply, mdl, team_id)
	local mdl_list = SUBGAMEMODE.CONFIG.PLAYERMODELS[team_id]
	if mdl_list then
		for k,v in pairs(mdl_list) do
			if v == mdl then
				ply.cs_playermodels[team_id] = mdl
				print("changed "..ply:Nick().."'s "..team_id.." playermodel to "..mdl)
				return
			end
		end
	end
end

function GM:DEFAULT_TeamChange(ply, team_id)
	if team_id == ply:CS16Team() then
		net.Start("cs16_change_team")
		net.Send(ply)
		ply:OldPrintMessage("You are already in that team.")
		return
	end

	--if ply.changed_team == true and game_state != GAMESTATE_NOTSTARTED then
	if ply.changed_team == true then
		ply:OldPrintMessage("You can only change your team once per round")
		return
	end

	if team_id == TEAM_SPECTATOR then
		ply.changed_team = true
		ply:SetCS16Team(TEAM_SPECTATOR, true)
		if ply:Alive() and !ply:IsSpectator() then
			ply:Kill()
		end
		return
	end

	local all_ts = {}
	local all_cts = {}

	for k,v in pairs(GAMEMODE:GetPlayers()) do
		--if v != ply then
			if v:CS16Team() == TEAM_T then
				table.ForceInsert(all_ts, v)

			elseif v:CS16Team() == TEAM_CT then
				table.ForceInsert(all_cts, v)
			end
		--end
	end

	local team_balance = #all_ts - #all_cts

	local should_change_to_t = false
	local should_change_to_ct = false

	if team_id == TEAM_UNASSIGNED then
		if team_balance < -1 then
			should_change_to_t = true

		elseif team_balance > 1 then
			should_change_to_ct = true
		end
	end

	if team_id == TEAM_T then
		if #all_ts <= #all_cts then
			should_change_to_t = true
		end

	elseif team_id == TEAM_CT then
		if #all_cts <= #all_ts then
			should_change_to_ct = true
		end
	end

	if should_change_to_t then
		ply:SetCS16Team(TEAM_T, true)
		PrintMessage(HUD_PRINTTALK, ply:Nick().." has joined the terrorist forces.")
		ply.changed_team = true
		if ply:Alive() and !ply:IsSpectator() and (game_state == GAMESTATE_ROUND or game_state == GAMESTATE_PREPARING) then
			ply:Kill()
		end
		net.Start("cs16_change_team")
		net.Send(ply)

	elseif should_change_to_ct then
		ply:SetCS16Team(TEAM_CT, true)
		PrintMessage(HUD_PRINTTALK, ply:Nick().." has joined the ct forces.")
		ply.changed_team = true
		if ply:Alive() and !ply:IsSpectator() and (game_state == GAMESTATE_ROUND or game_state == GAMESTATE_PREPARING) then
			ply:Kill()
		end
		net.Start("cs16_change_team")
		net.Send(ply)

	elseif team_id == TEAM_UNASSIGNED then
		net.Start("cs16_change_team")
		net.Send(ply)
	end
end

print("Gamemode loaded gamemodes/_defaults/sv_player_actions.lua")