GM_INITIALIZED = GM_INITIALIZED or false

include("core/client/cl_killicons.lua")

--include("XXXXXXXXXXX.lua")
include("core/shared/sh_enums.lua")
include("sh_gamemodes.lua")
include("shared.lua")
include("core/client/cl_networking.lua")
include("core/shared/sh_networking.lua")
include("core/client/cl_spectator.lua")
include("core/shared/sh_overrides.lua")
include("core/client/cl_player_ext.lua")
include("core/shared/sh_player_ext.lua")
include("core/shared/sh_player.lua")

include("core/client/cl_killfeed.lua")
include("core/client/cl_hud_util.lua")
include("core/client/cl_targetid.lua")
include("core/client/cl_hud_spectator.lua")
include("core/client/cl_hud_oldprintmessage.lua")
include("core/client/cl_hud_greennotif.lua")
include("core/client/cl_hud_uppernotif.lua")
include("core/client/cl_hud.lua")
include("core/client/cl_view.lua")
include("core/client/cl_scoreboard.lua")
include("core/client/cl_overrides.lua")
include("core/client/cl_menu_start.lua")
include("core/client/cl_menu_buy.lua")
include("core/client/cl_nvg.lua")
include("core/client/cl_chat.lua")

include("modules/sh_corpse_system.lua")
--include("modules/sh_flashlight_module.lua")
include("modules/sh_round_system_module.lua")

function GM:Initialize()
    print("GAMEMODE INITIALIZED: CLIENT")
    GM_INITIALIZED = true
end

local keybinds = {}
keybinds[KEY_N] = {
    pressed_bind = false,
    func = function()
        NVG_Toggle()
    end
}
keybinds[KEY_G] = {
    pressed_bind = false,
    func = function()
        net.Start("cs16_dropweapon")
        net.SendToServer()
    end
}
keybinds[KEY_B] = {
    pressed_bind = false,
    func = function()
        if buymenu_enabled then
            force_remove_buymenu()
        else
            CreateBuyMenu()
        end
    end
}
keybinds[KEY_M] = {
    pressed_bind = false,
    func = function()
        current_start_menu = "select_team"
        CreateStartMenu()
    end
}

local nkc = 0
hook.Add("HUDPaint", "cs16_gm_keybinds", function()
    if nkc > CurTime() then return end
    nkc = CurTime() + 0.01

    if !ispanel(vgui.GetKeyboardFocus()) then
        for k,v in pairs(keybinds) do
            if v.pressed_bind then
                if !input.IsKeyDown(k) then
                    v.pressed_bind = false
                end
            else
                if input.IsKeyDown(k) then
                    v.func()
                    v.pressed_bind = true
                end
            end
        end
    end
end)

print("Gamemode loaded cl_init.lua")