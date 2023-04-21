
--resource.AddWorkshop("2397781129")

SUBGAMEMODE = {}
SUBGAMEMODE.CONFIG = {}
SUBGAMEMODE.HOOKS = {}

AddCSLuaFile("cl_model_effects.lua")
AddCSLuaFile("cl_hud_select_team.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_player_ext.lua")
AddCSLuaFile("cl_hud_scoreboard.lua")
AddCSLuaFile("sh_config_shop_items.lua")
AddCSLuaFile("cl_hud_buy_items.lua")
include("shared.lua")
include("sv_player_ext.lua")
include("sh_player_ext.lua")

include("sv_time.lua")
include("sv_tick.lua")
include("sv_util.lua")

include("sv_player_death.lua")
include("sv_player_spawn.lua")
include("sv_player_damage.lua")
include("sv_player_buying.lua")

-- Prevent player from picking up objects
function SUBGAMEMODE:AllowPlayerPickup(ply, ent)
    if ply:IsZombie() then return false end
    return GAMEMODE:DEFAULT_AllowPlayerPickup(ply, ent)
end

-- Prevent player from picking up some weapons
function SUBGAMEMODE:PlayerCanPickupWeapon(ply, weapon)
    if ply:IsZombie() then return weapon.ZombieWeapon end
    return GAMEMODE:DEFAULT_PlayerCanPickupWeapon(ply, weapon)
end

-- Players can hear eachother
function SUBGAMEMODE:PlayerCanHearPlayersVoice(listener, talker)
    --return GAMEMODE:DEFAULT_PlayerCanHearPlayersVoice(listener, talker)
    if game_state == GAMESTATE_ROUND then
        -- Dead people don't talk
        if !talker:Alive() then return false end

        -- Spectator voice chat
        if talker:Team() == TEAM_SPECTATOR then
            return !listener:Alive() or listener:Team() == TEAM_SPECTATOR, false

        -- Zombie is talking
        elseif talker:Team() == TEAM_T then
            return listener:Team() == TEAM_T, false

        -- Human is talking
        elseif talker:Team() == TEAM_CT then
            local dist = talker:GetPos():Distance(listener:GetPos())
            return dist < 600, true
        else
            return false, false
        end
    else
        return true, false
    end
end

function SUBGAMEMODE:PlayerCanSeePlayersChat(text, teamOnly, listener, talker)
    if game_state != GAMESTATE_ROUND then
        return true
    end

    if !talker:Alive() then
        return false
    end

    if talker:Team() == TEAM_SPECTATOR then
        return (listener:Team() == TEAM_SPECTATOR)
    end

    if teamOnly then
        return (listener:Team() == talker:Team())
    end

    return true
end

GM:SubGamemodeHook_Add("CS16_OnPlayerFrozen", "CS16_ZM_OnFrozen", function(ply)
    ply:EmitSound(GetCS16Sound("GRENADE_FROST_PLAYER"))
end)

GM:SubGamemodeHook_Add("CS16_OnPlayerFreezeBreak", "CS16_ZM_OnFreezeBreak", function(ply)
    ply:EmitSound(GetCS16Sound("GRENADE_FROST_BREAK"))
end)

function SUBGAMEMODE.OnInitialize()
    print("Zombie mod initialized")

    gm_addcvar("cs16_zm_time_preparing", "45", "Zombie mod Preparing time")
    gm_addcvar("cs16_zm_time_round", "420", "Zombie mod Round time")
    gm_addcvar("cs16_zm_time_postround", "10", "Zombie mod Post-round time")
end



-- Player wants to join a team
function SUBGAMEMODE:TeamChange(ply, team_id)
    ply.WantToPlay = (team_id != TEAM_SPECTATOR)
    return
end

-- Player wants to change model
function SUBGAMEMODE:ModelChange(ply, mdl, team_id)
    --ply:OldPrintMessage("You cannot change your model")
    --return

    return GAMEMODE:DEFAULT_ModelChange(ply, mdl, team_id)
end

-- Player wants to drop current weapon
function SUBGAMEMODE:DropCurrentWeapon(ply)
    return GAMEMODE:DEFAULT_DropCurrentWeapon(ply)
end

include("sv_config_wins.lua")
include("sv_round.lua")
include("sh_config_shop_items.lua")

print("Gamemode loaded gamemodes/zombie_mod/init.lua")