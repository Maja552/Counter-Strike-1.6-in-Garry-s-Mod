GM_INITIALIZED = GM_INITIALIZED or false

--resource.AddWorkshop("2386682198")
--resource.AddWorkshop("2386684523")

-- SERVER LOADING EARLY FILES
include("core/shared/sh_enums.lua")
include("core/server/sv_cvars.lua")
include("sh_gamemodes.lua")

-- CLIENTSIDE FILES BEING SENT FROM THE SERVER
AddCSLuaFile("core/shared/sh_enums.lua")
AddCSLuaFile("sh_gamemodes.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("core/client/cl_networking.lua")
AddCSLuaFile("core/shared/sh_networking.lua")
AddCSLuaFile("core/shared/sh_overrides.lua")
AddCSLuaFile("core/client/cl_player_ext.lua")
AddCSLuaFile("core/shared/sh_player_ext.lua")
AddCSLuaFile("core/shared/sh_player.lua")
AddCSLuaFile("core/client/cl_killicons.lua")
AddCSLuaFile("core/client/cl_killfeed.lua")
AddCSLuaFile("core/client/cl_hud_util.lua")
AddCSLuaFile("core/client/cl_targetid.lua")
AddCSLuaFile("core/client/cl_hud_spectator.lua")
AddCSLuaFile("core/client/cl_hud_oldprintmessage.lua")
AddCSLuaFile("core/client/cl_hud_greennotif.lua")
AddCSLuaFile("core/client/cl_hud_uppernotif.lua")
AddCSLuaFile("core/client/cl_hud.lua")
AddCSLuaFile("core/client/cl_view.lua")
AddCSLuaFile("core/client/cl_scoreboard.lua")
AddCSLuaFile("core/client/cl_spectator.lua")
AddCSLuaFile("core/client/cl_overrides.lua")
AddCSLuaFile("core/client/cl_menu_start.lua")
AddCSLuaFile("core/client/cl_menu_buy.lua")
AddCSLuaFile("core/client/cl_nvg.lua")
AddCSLuaFile("core/client/cl_chat.lua")

AddCSLuaFile("modules/sh_corpse_system.lua")
--AddCSLuaFile("modules/sh_flashlight_module.lua")
AddCSLuaFile("modules/sh_round_system_module.lua")
-- should be the last gamemode file sent to the client
AddCSLuaFile("cl_init.lua")


-- SERVER LOADING FILES
include("shared.lua")
include("core/server/sv_networking.lua")
include("core/shared/sh_networking.lua")
include("core/shared/sh_overrides.lua")
include("core/server/sv_overrides.lua")
include("core/shared/sh_player_ext.lua")
include("core/server/sv_player_ext.lua")
include("core/server/sv_speeds.lua")
include("core/server/sv_player.lua")
include("core/shared/sh_player.lua")
include("core/server/sv_footsteps.lua")
include("core/server/sv_menu_buy.lua")
include("core/server/sv_spectator.lua")
include("core/server/sv_killfeed.lua")

include("modules/sh_corpse_system.lua")
--include("modules/sh_flashlight_module.lua")
include("modules/sh_round_system_module.lua")

-- after modules loaded
include("core/server/sv_round.lua")
include("debug.lua")

function GM:Initialize()
    print("GAMEMODE INITIALIZED: SERVER")
    GM_INITIALIZED = true
end

print("Gamemode loaded init.lua")