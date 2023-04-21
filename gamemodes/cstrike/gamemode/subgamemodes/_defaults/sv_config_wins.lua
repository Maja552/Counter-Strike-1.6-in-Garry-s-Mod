
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

GM.DEFAULT_CONFIG.CS16_LostRewards = function(win_id)
    local lost_id = 0
    if win_id == TEAM_T then
        lost_id = TEAM_CT
    else
        lost_id = TEAM_T
    end
    local won_two_consecutive = GAMEMODE:WonRoundNum(lost_id, round_id - 1) and GAMEMODE:WonRoundNum(lost_id, round_id - 2)
    if won_two_consecutive then
        GAMEMODE.RoundHistory[round_id].postround.won_two_consecutive = true
    end
    local lost_rounds_in_a_row = 1
    for i=1, table.Count(GAMEMODE.RoundHistory) + 1 do
        if GAMEMODE:LostRoundNum(lost_id, round_id - i) then
            lost_rounds_in_a_row = lost_rounds_in_a_row + 1
        end
    end
    if won_two_consecutive == false then
        for i=1, lost_rounds_in_a_row do
            local round = GAMEMODE.RoundHistory[round_id - i]
            if istable(round) then
                if round.postround.won_two_consecutive == true then
                    won_two_consecutive = true
                    continue
                end
                --if won_two_consecutive == true and round.postround.win_id then
                --	won_two_consecutive = false
                --	break
                --end
            end
        end
    end
    --print("TEAM "..lost_id.." LOST")
    --print("won_two_consecutive: ", won_two_consecutive)
    --print("lost_rounds_in_a_row: ", lost_rounds_in_a_row)

    local reward = 0
    local con_rewards = round_lost_rewards.consecutive
    local normal_rewards = round_lost_rewards.normal

    local num_of_con_rewards = table.Count(con_rewards)
    local num_of_normal_rewards = table.Count(con_rewards)

    if won_two_consecutive then
        if lost_rounds_in_a_row > num_of_con_rewards then
            reward = con_rewards[num_of_con_rewards]
        else
            reward = con_rewards[lost_rounds_in_a_row]
        end
    else
        if lost_rounds_in_a_row > num_of_normal_rewards then
            reward = normal_rewards[num_of_normal_rewards]
        else
            reward = normal_rewards[lost_rounds_in_a_row]
        end
    end

    print("team lost reward: ", reward)
    for k,v in pairs(player.GetAll()) do
        if v.changed_team != true and v:CS16Team() == lost_id then
            v:AddMoney(reward, false)
        end
    end
    GAMEMODE:UpdateAllMoney()
end

GM.DEFAULT_CONFIG.CS16_WinRewards = {
    time = function()
        team.AddScore(TEAM_CT, 1)
        for k,v in pairs(player.GetAll()) do
            if v.changed_team != true and v:CS16Team() == TEAM_CT then
                v:AddMoney(3250, false)
            end
        end
        OldPrintMessage("Target has been saved!")
        GAMEMODE:UpdateAllMoney()
    end,

    bomb = function()
        team.AddScore(TEAM_T, 1)
        for k,v in pairs(player.GetAll()) do
            if v.changed_team != true and v:CS16Team() == TEAM_T then
                v:AddMoney(3500, false)
            end
        end
        OldPrintMessage("Target successfully bombed!")
        GAMEMODE:UpdateAllMoney()
    end,

    elimination = function(win_id)
        team.AddScore(win_id, 1)
        local bomb_was_planted = GetGlobalBool("m_bBombPlanted", false)
        for k,v in pairs(player.GetAll()) do
            if v.changed_team != true then
                if v:CS16Team() == win_id then
                    v:AddMoney(3500, false)
                end
                -- SUCCESSFUL BOMB PLANT BONUS
                if bomb_was_planted and win_id == TEAM_CT and v:CS16TEAM() == TEAM_T then
                    v:AddMoney(800, false)
                end
            end
        end
        if win_id == TEAM_T then
            OldPrintMessage("Terrorists Win!")
        else
            OldPrintMessage("Counter-Terrorists Win!")
        end
        GAMEMODE:UpdateAllMoney()
    end
}

print("Gamemode loaded gamemodes/_defaults/sv_config_wins.lua")