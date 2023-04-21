
SUBGAMEMODE = {}
SUBGAMEMODE.CONFIG = {}
SUBGAMEMODE.HOOKS = {}-- note: cstrike doesnt have it

include("sh_player_ext.lua")
include("cl_networking.lua")
include("shared.lua")

-- Scoreboard player lists like Terrorists, Counter-Terrorists and Spectators
SUBGAMEMODE.CONFIG.HUD_Spect_PlayerLists = table.Copy(GM.DEFAULT_HUD_Spect_PlayerLists)
SUBGAMEMODE.CONFIG.MENU_SelectPlayerTeams = table.Copy(GM.DEFAULT_MENU_SelectPlayerTeams)
SUBGAMEMODE.CONFIG.MENU_SelectModels = table.Copy(GM.DEFAULT_MENU_SelectModels)
SUBGAMEMODE.CONFIG.SB_PlayerLists = table.Copy(GM.DEFAULT_SB_PlayerLists)
SUBGAMEMODE.CONFIG.MENU_MapDescription = GM.DEFAULT_MENU_MapDescription
SUBGAMEMODE.MENU_GetBuyMenuPages = GM.DEFAULT_MENU_GetBuyMenuPages

function reset_player(ply)
    ply.zombie_madness_til = 0
    ply.cloaked_til = 0
    ply.is_nemesis = false
end

-- Useful for adding effects when somebody gets damaged
function SUBGAMEMODE:CL_ScalePlayerDamage(ply, hitgroup, dmginfo)
    return GAMEMODE:DEFAULT_CL_ScalePlayerDamage(ply, hitgroup, dmginfo)
end

--NVG STUFF
function SUBGAMEMODE:NVG_EFFECTS()
    local client = LocalPlayer()
    local nvg_person = client
    if client:IsSpectator() and IsValid(client:GetObserverTarget()) and client:GetObserverMode() == OBS_MODE_IN_EYE then
        nvg_person = client:GetObserverTarget()
    end

    if !nvg_person.zombie_madness_til then return end
    
    local nvg_info = {
        contrast = 1,
        colour = 1,
        brightness = 0,
        clr_r = 0,
        clr_g = 0,
        clr_b = 0,
        add_r = 0,
        add_g = 0,
        add_b = 0
    }

    
    if nvg_person.zombie_madness_til > CurTime() or nvg_person.is_nemesis then
        nvg_info.contrast = 1.5
        nvg_info.add_r = 0.15
        nvg_info.clr_r = 0.9
        nvg_info.brightness = -0.2
        return nvg_info
    end

    local nvg_enabled = (nvg_person:GetNWBool("HasNVG", false) and nvg_person.CS16_NVG_ENABLED)
    if nvg_enabled or nvg_person:HasZombieClaws() then
        nvg_info.contrast = 2.5
        nvg_info.add_g = 0.15
        nvg_info.clr_g = 0.9
        nvg_info.brightness = -0.2
        return nvg_info
    end

    if game_state == GAMESTATE_PREPARING then
        nvg_info.contrast = 1.5
        nvg_info.brightness = 0.02
        return nvg_info
    end
end

print("Gamemode loaded gamemodes/zombie_plague/cl_init.lua")