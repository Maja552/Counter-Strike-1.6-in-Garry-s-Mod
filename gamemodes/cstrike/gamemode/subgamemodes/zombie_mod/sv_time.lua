
-- Returns win team and win reason
function SUBGAMEMODE.OnRoundTimeReached()
    return GAMEMODE:DEFAULT_OnRoundTimeReached()
end

-- The time length of the preparing phase
function SUBGAMEMODE:GetPreparingTime()
    return cvars.Number("cs16_zm_time_preparing", 30)
end

-- The time length of the round phase
function SUBGAMEMODE:GetRoundTime()
    return cvars.Number("cs16_zm_time_round", 420)
end

-- The time length of the postround phase
function SUBGAMEMODE:GetPostroundTime()
    return cvars.Number("cs16_zm_time_postround", 10)
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

-- Happens just before the end of the round start
function SUBGAMEMODE:Post_RoundStart()
    GAMEMODE:DEFAULT_Post_RoundStart()
end

print("Gamemode loaded gamemodes/zombie_mod/sv_time.lua")