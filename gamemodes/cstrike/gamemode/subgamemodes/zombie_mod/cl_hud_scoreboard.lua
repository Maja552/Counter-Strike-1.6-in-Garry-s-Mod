
SUBGAMEMODE.CONFIG.SB_PlayerLists = {
    [TEAM_CT] = {
        name = function()
            if game_state == GAMESTATE_PREPARING then
                return "Counter-Terrorists"
            end
            return "Human Coalition"
        end,
        clr = Color(161, 201, 255),
        tab = {},
        show_infos = true
    },
    [TEAM_T] = {
        name = function()
            if game_state == GAMESTATE_PREPARING then
                return "Terrorists"
            end
            return "Zombies"
        end,
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

print("Gamemode loaded gamemodes/zombie_mod/cl_hud_scoreboard.lua")