
SUBGAMEMODE.CONFIG.MENU_SelectPlayerTeams = {
    {
        text = "PLAY",
        select_model = false,
        func = function()
            net.Start("cs16_change_team")
                net.WriteInt(TEAM_UNASSIGNED, 16)
            net.SendToServer()
            --startmenu_frame:Remove()
        end,
    },
    {
        text = "SPECTATE",
        select_model = false,
        func = function()
            print("spectating...")
            net.Start("cs16_change_team")
                net.WriteInt(TEAM_SPECTATOR, 16)
            net.SendToServer()
            startmenu_frame:Remove()
        end,
    },
    1,
    {
        text = "SELECT T MODEL",
        select_model = false,
        func = function()
            startmenu_frame:Remove()
            current_start_menu = "select_model"
            force_model_team = TEAM_T
            CreateStartMenu()
        end,
    },
    {
        text = "SELECT CT MODEL",
        select_model = false,
        func = function()
            startmenu_frame:Remove()
            current_start_menu = "select_model"
            force_model_team = TEAM_CT
            CreateStartMenu()
        end,
    },
    1,
    {
        text = "CANCEL",
        select_model = false,
        func = function()
            startmenu_frame:Remove()
        end,
    },
}

print("Gamemode loaded gamemodes/zombie_mod/cl_hud_select_team.lua")