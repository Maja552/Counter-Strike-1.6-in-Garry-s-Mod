
SUBGAMEMODE = {}
SUBGAMEMODE.CONFIG = {}

AddCSLuaFile("shared.lua")
include("shared.lua")


function SUBGAMEMODE:CanPlayerSuicide(ply)
    return GAMEMODE:DEFAULT_CanPlayerSuicide(ply)
end

function SUBGAMEMODE:PlayerCanBuy(ply)
    return ply:GetNWBool("CanBuy", false)
end

-- Returns win team and win reason
function SUBGAMEMODE.OnRoundTimeReached()
    return GAMEMODE:DEFAULT_OnRoundTimeReached()
end

-- Prevent player from picking up objects
function SUBGAMEMODE:AllowPlayerPickup(ply, ent)
    return GAMEMODE:DEFAULT_AllowPlayerPickup(ply, ent)
end

-- Prevent player from picking up some weapons
function SUBGAMEMODE:PlayerCanPickupWeapon(ply, weapon)
    return GAMEMODE:DEFAULT_PlayerCanPickupWeapon(ply, weapon)
end

-- The time length of the preparing phase
function SUBGAMEMODE:GetPreparingTime()
    return GAMEMODE:DEFAULT_GetPreparingTime()
end

-- The time length of the round phase
function SUBGAMEMODE:GetRoundTime()
    return GAMEMODE:DEFAULT_GetRoundTime()
end

-- The time length of the postround phase
function SUBGAMEMODE:GetPostroundTime()
    return GAMEMODE:DEFAULT_GetPostroundTime()
end

-- Returns if we should start the game or not
function SUBGAMEMODE:WinCheck()
	return GAMEMODE:DEFAULT_WinCheck()
end

-- Returns if we should start the game or not
function SUBGAMEMODE:ShouldStartGame()
	return GAMEMODE:DEFAULT_ShouldStartGame()
end

-- Happens just before the end of the postround start
function SUBGAMEMODE:Post_PostRoundStart(win_id, win_reason)
    GAMEMODE:DEFAULT_Post_PostRoundStart(win_id, win_reason)
end

-- Happens just before the end of the preparing start
function SUBGAMEMODE:Post_Preparing()
    GAMEMODE:DEFAULT_Post_Preparing()
end

-- Happens just before the end of the round start
function SUBGAMEMODE:Post_RoundStart()
    GAMEMODE:DEFAULT_Post_RoundStart()
end

-- Players can hear eachother
function SUBGAMEMODE:PlayerCanHearPlayersVoice(listener, talker)
    return GAMEMODE:DEFAULT_PlayerCanHearPlayersVoice(listener, talker)
end

function SUBGAMEMODE:PlayerCanSeePlayersChat(text, teamOnly, listener, talker)
    return GAMEMODE:DEFAULT_PlayerCanSeePlayersChat(text, teamOnly, listener, talker)
end

-- Player damage sounds
function SUBGAMEMODE:PlayerDamageSounds(ply, hitgroup, dmginfo)
    GAMEMODE:DEFAULT_PlayerDamageSounds(ply, hitgroup, dmginfo)
end

-- Should player take damage, prevents team damage
function SUBGAMEMODE:PlayerShouldTakeDamage(ply, attacker)
    return GAMEMODE:DEFAULT_PlayerShouldTakeDamage(ply, attacker)
end

-- Player damage scaling
function SUBGAMEMODE:ScalePlayerDamage(ply, hitgroup, dmginfo)
    GAMEMODE:DEFAULT_ScalePlayerDamage(ply, hitgroup, dmginfo)
end

-- Before the player's death
function SUBGAMEMODE:DoPlayerDeath(ply, attacker, dmginfo)
    GAMEMODE:DEFAULT_DoPlayerDeath(ply, attacker, dmginfo)
end

-- After the player's death
function SUBGAMEMODE:PostPlayerDeath(ply)
    GAMEMODE:DEFAULT_PostPlayerDeath(ply)
end

-- Player ded
function SUBGAMEMODE:PlayerDeath(ply, inflictor, attacker)
    GAMEMODE:DEFAULT_PlayerDeath(ply, inflictor, attacker)
end

-- When the player is dead
function SUBGAMEMODE:PlayerDeathThink(ply)
    GAMEMODE:DEFAULT_PlayerDeathThink(ply)
end

-- The corpse death sound, better position
function SUBGAMEMODE:DoCorpseDeathSound(ply, corpse)
    return GAMEMODE:DEFAULT_DoCorpseDeathSound(ply, corpse)
end

-- The death sound
function SUBGAMEMODE:PlayerDeathSound(ply)
    return GAMEMODE:DEFAULT_PlayerDeathSound(ply)
end

-- First spawn
function SUBGAMEMODE:OnPlayerInitialSpawn(ply)
    return GAMEMODE:DEFAULT_OnPlayerInitialSpawn(ply)
end

-- Player spawns
function SUBGAMEMODE:PlayerSpawn(ply)
    return GAMEMODE:DEFAULT_PlayerSpawn(ply)
end

-- Player wants to join a team
function SUBGAMEMODE:TeamChange(ply, team_id)
    return GAMEMODE:DEFAULT_TeamChange(ply, team_id)
end

-- Player wants to change model
function SUBGAMEMODE:ModelChange(ply, mdl, team_id)
    return GAMEMODE:DEFAULT_ModelChange(ply, mdl, team_id)
end

-- Player wants to drop current weapon
function SUBGAMEMODE:DropCurrentWeapon(ply)
    return GAMEMODE:DEFAULT_DropCurrentWeapon(ply)
end

print("Gamemode loaded gamemodes/hide_and_seek/init.lua")