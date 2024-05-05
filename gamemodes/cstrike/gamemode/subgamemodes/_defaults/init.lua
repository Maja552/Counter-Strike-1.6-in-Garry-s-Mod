
AddCSLuaFile("cl_hud_buy_items.lua")
AddCSLuaFile("cl_hud_scoreboard.lua")
AddCSLuaFile("cl_hud_select_model.lua")
AddCSLuaFile("cl_hud_select_team.lua")

AddCSLuaFile("sh_config_shop_items.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("sv_player_death.lua")
include("sv_player_spawn.lua")
include("sv_player_actions.lua")

function GM:DEFAULT_CanPlayerSuicide(ply)
    return true
end

function GM:DEFAULT_OnRoundTimeReached()
    return WIN_TIME, WIN_TIME
end

function DEFAULT_AllowPlayerPickup(ply, ent)
    return (ply:Alive() and !ply:IsSpectator())
end

function GM:DEFAULT_PlayerCanPickupWeapon(ply, weapon)
    if !ply:Alive() or ply:IsSpectator() or (weapon.OnlyTeam and weapon.OnlyTeam != ply:Team()) then return false end
	if weapon.PaintballGun then return true end

	for k,v in pairs(ply:GetWeapons()) do
		if v.Slot == weapon.Slot and v.SlotPos == weapon.SlotPos then
			return false
		end
	end

	if weapon.OnPickup then
		weapon:OnPickup(ply)
	end
	return true
end

function GM:DEFAULT_GetPreparingTime()
    return cvars.Number("cs16_time_preparing", DEFAULT_CVAR_VALUES["cs16_time_preparing"])
end

function GM:DEFAULT_GetRoundTime()
    return cvars.Number("cs16_time_round", DEFAULT_CVAR_VALUES["cs16_time_round"])
end

function GM:DEFAULT_GetPostroundTime()
    return cvars.Number("cs16_time_postround", DEFAULT_CVAR_VALUES["cs16_time_postround"])
end

function GM:DEFAULT_ShouldStartGame()
	local all_ts = #GAMEMODE:GetAllCS16TeamPlayers(TEAM_T)
	local all_cts = #GAMEMODE:GetAllCS16TeamPlayers(TEAM_CT)
	return (all_ts > 0 and all_cts > 0)
end

function GM:DEFAULT_PlayerCanHearPlayersVoice(listener, talker)
    if !talker:Alive() or talker:IsSpectator() then
        return (!listener:Alive() or listener:IsSpectator())
    end
    return (listener:Team() == talker:Team())
end

function GM:DEFAULT_PlayerCanSeePlayersChat(text, teamOnly, listener, talker)
    return true
end

function GM:DEFAULT_PlayerDamageSounds(ply, hitgroup, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if IsValid(attacker) and attacker:IsPlayer() and SUBGAMEMODE:PlayerShouldTakeDamage(ply, attacker) == false then return true end
    
    if hitgroup == HITGROUP_HEAD then
		if ply:GetNWBool("HasHelmet", false) then
			ply:EmitSound("cstrike/player/bhit_helmet-1.wav")
		else
			ply:EmitSound("cstrike/player/headshot"..math.random(1,3)..".wav")
		end
	end
end

function GM:DEFAULT_PlayerShouldTakeDamage(ply, attacker)
    if !IsValid(attacker) or !attacker:IsPlayer() or ply == attacker then return true end
	return (ply:Team() != attacker:Team())
end

function GM:DEFAULT_ScalePlayerDamage(ply, hitgroup, dmginfo)
    local attacker = dmginfo:GetAttacker()
    local dmg_mul = 1
    if hitgroup == HITGROUP_HEAD then
        if !ply:GetNWBool("HasHelmet", false) then
            dmg_mul = dmg_mul * 2
        end

    elseif hitgroup == HITGROUP_LEFTARM or hitgroup == HITGROUP_RIGHTARM or hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG then
        dmg_mul = dmg_mul * 0.75
    end

    --if IsValid(attacker) and attacker:IsPlayer() and ply:Team() == attacker:Team() then
    --    dmg_mul = 0
    --end
    dmginfo:ScaleDamage(dmg_mul)

    if dmg_mul == 0 then
        return true
    end
end

include("sv_round.lua")

print("Gamemode loaded gamemodes/_defaults/init.lua")