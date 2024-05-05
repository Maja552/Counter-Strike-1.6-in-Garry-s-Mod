
SUBGAMEMODE = {}
SUBGAMEMODE.CONFIG = {}

include("shared.lua")

-- Scoreboard player lists like Terrorists, Counter-Terrorists and Spectators
SUBGAMEMODE.CONFIG.HUD_Spect_PlayerLists = table.Copy(GM.DEFAULT_HUD_Spect_PlayerLists)
SUBGAMEMODE.CONFIG.MENU_SelectPlayerTeams = table.Copy(GM.DEFAULT_MENU_SelectPlayerTeams)
SUBGAMEMODE.CONFIG.MENU_SelectModels = table.Copy(GM.DEFAULT_MENU_SelectModels)
SUBGAMEMODE.CONFIG.SB_PlayerLists = table.Copy(GM.DEFAULT_SB_PlayerLists)
SUBGAMEMODE.CONFIG.MENU_MapDescription = GM.DEFAULT_MENU_MapDescription
SUBGAMEMODE.MENU_GetBuyMenuPages = GM.DEFAULT_MENU_GetBuyMenuPages

function SUBGAMEMODE:NVG_EFFECTS()
    return GAMEMODE:DEFAULT_NVG_EFFECTS()
end

-- Useful for adding effects when somebody gets damaged
function SUBGAMEMODE:CL_ScalePlayerDamage(ply, hitgroup, dmginfo)
    return GAMEMODE:DEFAULT_CL_ScalePlayerDamage(ply, hitgroup, dmginfo)
end

print("Gamemode loaded gamemodes/paintball/cl_init.lua")