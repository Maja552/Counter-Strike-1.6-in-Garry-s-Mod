
GM.DEFAULT_SB_PlayerLists = {
    [TEAM_CT] = {
        name = "Counter-Terrorists",
        clr = Color(161, 201, 255),
        tab = {},
        show_infos = true
    },
    [TEAM_T] = {
        name = "Terrorists",
        clr = Color(255, 75, 75),
        tab = {},
        show_infos = true
    },
    [TEAM_SPECTATOR] = {
        name = "Spectators",
        clr = sb_color_main,
        clr2 = Color(255, 255, 255),
        tab = {},
        show_infos = false
    }
}

print("Gamemode loaded gamemodes/_defaults/cl_hud_scoreboard.lua")