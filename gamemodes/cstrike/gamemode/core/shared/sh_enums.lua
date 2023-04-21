
TEAM_T = 1
TEAM_T_NAME = "Terrorists"
TEAM_T_CLR = Color(255, 75, 75)

TEAM_CT = 2
TEAM_CT_NAME = "Counter-Terrorists"
TEAM_CT_CLR = Color(161, 201, 255)

TEAM_SZ = 3
TEAM_SZ_NAME = "Spetznaz"
TEAM_SZ_CLR = Color(200, 200, 200)

WIN_TIME = 10
WIN_ELIMINATION = 11
WIN_BOMB = 12
WIN_DRAW = 62

GAMESTATE_NOTSTARTED = 0
GAMESTATE_PREPARING = 1
GAMESTATE_ROUND = 2
GAMESTATE_POSTROUND = 3
GAMESTATE_ROUND_END = 4

GM_HOOKS_PREFIX = "CS16_"

DEFAULT_CVAR_VALUES = {}
DEFAULT_CVAR_VALUES["cs16_time_preparing"] = 5
DEFAULT_CVAR_VALUES["cs16_time_buyphase"] = 60
DEFAULT_CVAR_VALUES["cs16_time_round"] = 300
DEFAULT_CVAR_VALUES["cs16_time_postround"] = 5

cs16_main_color = Color(255, 170, 0, 255)
cs16_greennotif_color = Color(75, 255, 75, 255)
cs16_notif_human_color = Color(0, 100, 255, 255)

cs16_survivor_beam_color = Color(0,0,255)

sb_color_main = cs16_main_color
sb_color_bg_1 = Color(20, 20, 20, 200)

sb_bg_w = 1170
sb_bg_h = 766
ui_button_w = 288
ui_button_h = 45
ui_button_hovered_color = Color(255, 170, 0, 30)

function GetLang(key)
    if istable(SUBGAMEMODE.CONFIG.LANG) then
        return SUBGAMEMODE.CONFIG.LANG[key]
    end
end

function GetLangRep(key, tab)
    if istable(SUBGAMEMODE.CONFIG.LANG) then
        local str = SUBGAMEMODE.CONFIG.LANG[key]
        for k,v in pairs(tab) do
            str = string.Replace(str, v[1], v[2])
        end
        return str
    end
end

print("Gamemode loaded sh_enums.lua")