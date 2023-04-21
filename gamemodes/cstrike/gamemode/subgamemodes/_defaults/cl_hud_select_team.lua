
GM.DEFAULT_MENU_SelectPlayerTeams = {
    {
        text = "TERRORIST FORCES",
        select_model = true,
        func = function()
            print("trying to join the terrorist forces...")
            net.Start("cs16_change_team")
                net.WriteInt(TEAM_T, 16)
            net.SendToServer()
            --startmenu_frame:Remove()
        end,
    },
    {
        text = "CT FORCES",
        select_model = true,
        func = function()
            print("trying to join the ct forces...")
            net.Start("cs16_change_team")
                net.WriteInt(TEAM_CT, 16)
            net.SendToServer()
            --startmenu_frame:Remove()
        end,
    },
    1,
    {
        text = "AUTO ASSIGN",
        select_model = true,
        func = function()
            print("telling the server to auto assign us...")
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
    {
        text = "CANCEL",
        select_model = false,
        func = function()
            startmenu_frame:Remove()
        end,
    }
}

print("Gamemode loaded gamemodes/_defaults/cl_hud_select_team.lua")