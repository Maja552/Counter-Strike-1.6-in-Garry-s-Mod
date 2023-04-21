-- MODULE CONFIG
local gm_preparing_time_cvar = "cs16_time_preparing"
local gm_round_time_cvar = "cs16_time_round"
local gm_postround_time_cvar = "cs16_time_postround"

local function should_start_game()
	if !SUBGAMEMODE then return false end
	return SUBGAMEMODE:ShouldStartGame()
end

-- MODULE INFO
--  Added new hooks:
--   RoundModule_PreparingStart
--   RoundModule_PreparingStart_Post
--   RoundModule_RoundStart
--   RoundModule_RoundStart_Post
--   RoundModule_PostRoundStart
--   RoundModule_RoundEnd
--   RoundModule_WinCheck



-- MODULE: Round system
if SERVER then
	local roundmodule_hook_prefix = "RoundModule_"
	if round_module == nil then
		round_module = {}

		game_state = GAMESTATE_NOTSTARTED
		round_state_end = 0
		round_state_start = 0
		game_state_preparing_timestamp = math.huge
		game_state_round_timestamp = math.huge
		game_state_postround_timestamp = math.huge
		game_state_roundend_timestamp = math.huge
	end

	round_module.PreparingStart = function()
		local result = hook.Call(roundmodule_hook_prefix.."PreparingStart")
		if result == true then return end

		game_state = GAMESTATE_PREPARING
		game_state_preparing_timestamp = CurTime()
		game_state_round_timestamp = math.huge
		game_state_postround_timestamp = math.huge
		game_state_roundend_timestamp = math.huge

		hook.Call(roundmodule_hook_prefix.."PreparingStart_Post")
	end

	round_module.RoundStart = function()
		local result = hook.Call(roundmodule_hook_prefix.."RoundStart")
		if result == true then return end

		game_state = GAMESTATE_ROUND
		game_state_round_timestamp = CurTime()

		hook.Call(roundmodule_hook_prefix.."RoundStart_Post")
	end

	round_module.PostRoundStart = function(win_id, win_reason)
		local result = hook.Call(roundmodule_hook_prefix.."PostRoundStart", GAMEMODE, win_id, win_reason)
		if result == true then return end

		game_state = GAMESTATE_POSTROUND
		game_state_postround_timestamp = CurTime()
	end

	round_module.RoundEnd = function()
		local result = hook.Call(roundmodule_hook_prefix.."RoundEnd")
		if result == true then return end

		game_state = GAMESTATE_ROUND_END
		game_state_roundend_timestamp = CurTime()
	end

	round_module.TimeLeft = function()
		return round_state_end - CurTime()
	end

	function Debug_NextRoundStage()
		if round_state_end < CurTime() then
			if game_state == GAMESTATE_NOTSTARTED or game_state == GAMESTATE_ROUND_END then
				game_state = GAMESTATE_PREPARING

			elseif game_state == GAMESTATE_PREPARING then
				game_state = GAMESTATE_ROUND
				
			elseif game_state == GAMESTATE_ROUND then
				game_state = GAMESTATE_POSTROUND
				
			elseif game_state == GAMESTATE_POSTROUND then
				game_state = GAMESTATE_ROUND_END
			end
		end
		round_state_end = 0
		round_state_start = 0
	end

	function WinCheck()
		local win_id, win_reason = hook.Call(roundmodule_hook_prefix.."WinCheck")
		return win_id or 0, win_reason
	end

	ngst = 0

	hook.Add("PlayerInitialSpawn", roundmodule_hook_prefix.."InitialSpawn", function(ply)
		ngst = CurTime() + 2
	end)

	local function getfcvar(name)
		local cvar = GetConVar(name)
		if cvar == nil then return 0 end
		return cvar:GetInt()
	end

	function HandleRounds()
		if game_state == GAMESTATE_NOTSTARTED then
			if ngst > CurTime() then return end
			if !should_start_game() then
				ngst = CurTime() + 1
				return
			end
			round_state_end = 0
			round_state_start = 0
			print("0 - game started")
		end

		local win_check, win_reason = WinCheck()
		if !(game_state == GAMESTATE_ROUND and win_check > 0) then
			if round_state_end > CurTime() then return end
		end

		if game_state == GAMESTATE_NOTSTARTED or game_state == GAMESTATE_ROUND_END then
			round_state_end = CurTime() + GAMEMODE:GetPreparingTime()
			round_state_start = CurTime()
			round_module.PreparingStart()
			print("1 - preparing started")

		elseif game_state == GAMESTATE_PREPARING then
			round_state_end = CurTime() + GAMEMODE:GetRoundTime()
			round_state_start = CurTime()
			round_module.RoundStart()
			print("2 - round started")
			
		elseif game_state == GAMESTATE_ROUND or (win_check > 0 and game_state != GAMESTATE_POSTROUND) then
			round_state_end = CurTime() + GAMEMODE:GetPostroundTime()
			round_state_start = CurTime()
			if win_check == 0 and win_reason == nil then
				win_check, win_reason = SUBGAMEMODE.OnRoundTimeReached()
			end
			round_module.PostRoundStart(win_check, win_reason)
			print("3 - round ended, starting postround")
			
		elseif game_state == GAMESTATE_POSTROUND then
			round_state_end = CurTime() + 0.5
			round_state_start = CurTime()
			round_module.RoundEnd()
			print("4 - starting new round")
		end
	end
	hook.Add("Tick", roundmodule_hook_prefix.."Tick", HandleRounds)
end

-- TIME STUFF
if SERVER then
	local next_gamestate_update = 0

	util.AddNetworkString("roundmodule_gamestate")

	local function networking_tick()
		if !GM_INITIALIZED or !game_state then return end
		if next_gamestate_update < CurTime() then
			net.Start("roundmodule_gamestate")
				net.WriteInt(game_state, 8)
				net.WriteInt(math.Round(round_module.TimeLeft()), 16)
				net.WriteFloat(math.Clamp(-(CurTime()-round_state_end), 0, 32767))
			net.Broadcast()
			next_gamestate_update = CurTime() + 0.5
		end
	end
	hook.Add("Tick", "networking_tick", networking_tick)
else
	game_state = 0
	game_state_time_left = 0
	
	net.Receive("roundmodule_gamestate", function(len)
		game_state = net.ReadInt(8)
		game_state_time_left = net.ReadInt(16)
	end)
end

print("Gamemode loaded module: Round system")