
GM.DEFAULT_CONFIG = {
	-- Speed related things
    DEFAULT_WALK_SPEED = 250,
    DEFAULT_WALK_SPEED_SHIFT = 125,
	DEFAULT_JUMP_POWER = 200,
	
	JUMP_PENTALY_ENABLED = false,
	PREPARING_FREEZE = true,

	BOMB_DETONATION_TIME = 45,

	INFINITE_AMMO = false,

	-- Spawn related things
    ASSIGN_TEAMS = {
        [TEAM_CT] = function(ply)
            GAMEMODE:SetCT(ply)
        end,
        [TEAM_T] = function(ply)
            GAMEMODE:SetT(ply)
        end
	},
	
	-- Set to true if you want to make spawnpoints for all teams
	UNIFIED_SPAWNPOINTS = false,

    SPAWNPOINTS = {
        [TEAM_CT] = "info_player_counterterrorist",
        [TEAM_T] = "info_player_terrorist"
	},
	
	PLAYERMODELS = {
		[TEAM_CT] = {
			"models/cs/playermodels/gign.mdl",
			"models/cs/playermodels/gsg9.mdl",
			"models/cs/playermodels/sas.mdl",
			"models/cs/playermodels/urban.mdl"
		},
		[TEAM_T] = {
			"models/cs/playermodels/arctic.mdl",
			"models/cs/playermodels/leet.mdl",
			"models/cs/playermodels/guerilla.mdl",
			"models/cs/playermodels/terror.mdl"
		}
	},

	-- Buying related things
    STARTING_MONEY = 800,
	MAX_MONEY = 16000,
	CAN_ALWAYS_BUY = false,
	BUYING_ENABLED = true,

	FLASHLIGHT_ENABLED = false,

	WinConditions = {
		[TEAM_T] = {
			on_win_cl = function()
				print("the terrorists have won the round!")
				surface.PlaySound('cstrike/radio/terwin.wav')
			end
		},
		[TEAM_CT] = {
			on_win_cl = function()
				print("the counter-terrorists have won the round!")
				surface.PlaySound('cstrike/radio/ctwin.wav')
			end
		},
		[WIN_DRAW] = {
			on_win_cl = function()
				print("round draw")
				surface.PlaySound('cstrike/radio/rounddraw.wav')
			end
		}
	}
}

include("sh_config_shop_items.lua")

if SERVER then
	include("sv_config_wins.lua")
end

print("Gamemode loaded gamemodes/_defaults/shared.lua")