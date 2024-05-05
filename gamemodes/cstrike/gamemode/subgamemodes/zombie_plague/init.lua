
SUBGAMEMODE = {}
SUBGAMEMODE.CONFIG = {}
SUBGAMEMODE.HOOKS = {} -- note: cstrike doesnt have it

AddCSLuaFile("sh_player_ext.lua")
AddCSLuaFile("cl_networking.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("sv_tick.lua")
include("sv_player_ext.lua")


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

CS16_ZM_FiredCountDown = false

util.AddNetworkString("cs16_zm_prepstart")
-- Happens just before the end of the preparing start
function SUBGAMEMODE:Post_Preparing()
    CS16_ZM_FiredCountDown = false

    for k,v in pairs(player.GetAll()) do
        if v:Team() == TEAM_UNASSIGNED or (v.NextSpawnTime and v.NextSpawnTime > CurTime()) then
            v:SetTeam(TEAM_SPECTATOR)
            v:Spawn()
        end
    end

	GAMEMODE:DEFAULT_Assign_Players()

    local all_plys = GAMEMODE:GetPlayers()

    -- Spawn all players, resets their things and sets the model
    for k,v in pairs(all_plys) do
        v:SetDefaultVariables()
        v:Spawn()
    end

    local team_tab = {}

    -- Give loadout weapons, money
    for k,v in pairs(all_plys) do
        v:SetTeam(v:CS16Team())

        local team_assign_func = GAMEMODE.CONFIG.ASSIGN_TEAMS[v:Team()]
        if team_assign_func then
            team_assign_func(v)
        end
        if v.changed_team or #v:GetWeapons() == 0 then
            hook.Call("PlayerStripLoadout", GAMEMODE, v)
            hook.Call("PlayerLoadout", GAMEMODE, v)
        end

        table.ForceInsert(team_tab, {v, v:CS16Team()})

        v:SetNWBool("CanBuy", true)
    end

    -- Update the cs16_team of all players
	net.Start("cs16_zm_prepstart")
        net.WriteTable(team_tab)
	net.Broadcast()

    -- Sends the money information to all clients
    GAMEMODE:UpdateAllMoney()

    RunConsoleCommand("sv_accelerate", "8")

    Notification("upper", 6, GetLang("NOTICE_VIRUS_FREE"), Color(0, 125, 200))
end

util.AddNetworkString("cs16_zm_roundstart")
-- Happens just before the end of the round start
function SUBGAMEMODE:Post_RoundStart()
    local all_plys = player.GetAll()
    local first_zombie = table.Random(all_plys)
    first_zombie = Entity(1)
    table.RemoveByValue(all_plys, first_zombie)

    --CS16_ZM_ROUNDTYPES

    first_zombie:SetTeam(TEAM_T)
    first_zombie:Infect()
    Notification("upper", 2, GetLangRep("NOTICE_FIRST", {{"%s", first_zombie:Nick()}}), Color(255,0,0, 200))

    for k,v in pairs(all_plys) do
        v:SetTeam(TEAM_CT)
    end

	net.Start("cs16_zm_roundstart")
	net.Broadcast()
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
    if game_state == GAMESTATE_PREPARING then return false end
    if !IsValid(attacker) or !attacker:IsPlayer() or ply == attacker then return true end
	return (ply:Team() != attacker:Team())
end

-- Player damage scaling
function SUBGAMEMODE:ScalePlayerDamage(ply, hitgroup, dmginfo)
    GAMEMODE:DEFAULT_ScalePlayerDamage(ply, hitgroup, dmginfo)

    local attacker = dmginfo:GetAttacker()
    if attacker:Team() == TEAM_T and ply:Team() == TEAM_CT and dmginfo:GetDamage() + 2 >= ply:Health() then
        ply:Infect(attacker)
    end
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

-- The corpse death sound
function SUBGAMEMODE:DoCorpseDeathSound(ply, corpse)
    return GAMEMODE:DEFAULT_DoCorpseDeathSound(ply, corpse)
end

-- Make the player corpse
function SUBGAMEMODE:MakePlayerRagdoll(ply)
    return GAMEMODE:DEFAULT_MakePlayerRagdoll(ply)
end

-- The death sound
function SUBGAMEMODE:PlayerDeathSound(ply)
    return GAMEMODE:DEFAULT_PlayerDeathSound(ply)
end

-- First spawn
function SUBGAMEMODE:OnPlayerInitialSpawn(ply)
    ply:SetDefaultVariables()
    return GAMEMODE:DEFAULT_OnPlayerInitialSpawn(ply)
end

-- Player spawns
function SUBGAMEMODE:PlayerSpawn(ply)
    return GAMEMODE:DEFAULT_PlayerSpawn(ply)
end

-- Player set human (basically spawns and resets the player)
function SUBGAMEMODE:PlayerSetHuman(ply)
    return GAMEMODE:DEFAULT_PlayerSetHuman(ply)
end

-- Player loadout
function SUBGAMEMODE:PlayerLoadout(ply)
    return GAMEMODE:DEFAULT_PlayerLoadout(ply)
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

print("Gamemode loaded gamemodes/zombie_plague/init.lua")