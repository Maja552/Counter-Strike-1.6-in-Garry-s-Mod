
local round_lost_rewards = {
	normal = {
		1400,
		1900,
		2400,
		2900,
		3400
	},
	consecutive = {
		1500,
		2000,
		2500,
		3000
	}
}

SUBGAMEMODE.CONFIG.CS16_LostRewards = function(win_id)
    /*
    local lost_id = 0
    if win_id == TEAM_T then
        lost_id = TEAM_CT
    else
        lost_id = TEAM_T
    end

    for k,v in pairs(player.GetAll()) do
        if v.changed_team != true and v:Team() == lost_id then
            v:AddMoney(1000, false)
        end
    end
    GAMEMODE:UpdateAllMoney()
    */
end

SUBGAMEMODE.CONFIG.CS16_WinRewards = {
    time = function()
        --Notification("upper", 7, GetLang("WIN_NO_ONE"), Color(0,200,0))

        team.AddScore(TEAM_CT, 1)
        for k,v in pairs(player.GetAll()) do
            if v.changed_team != true and v:Team() == TEAM_CT then
                v:AddMoney(4000, false)
            else
                v:AddMoney(2500, false)
            end
        end
        GAMEMODE:UpdateAllMoney()
        Notification("upper", 7, GetLang("WIN_HUMANS_TIME"), cs16_notif_human_color)
    end,

    elimination = function(win_id)
        team.AddScore(win_id, 1)

        local reward = 3000
        if win_id == TEAM_CT then
            reward = 4000
        end

        for k,v in pairs(player.GetAll()) do
            if v.changed_team != true and v:Team() == win_id then
                v:AddMoney(reward, false)
            end
        end
        if win_id == TEAM_T then
            Notification("upper", 6, GetLang("WIN_ZOMBIE"), Color(255,0,0))
        else
            Notification("upper", 6, GetLang("WIN_HUMAN"), cs16_notif_human_color)
        end
        GAMEMODE:UpdateAllMoney()
    end
}

print("Gamemode loaded gamemodes/zombie_mod/sv_config_wins.lua")