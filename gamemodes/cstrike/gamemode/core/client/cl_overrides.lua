
function GM:ScalePlayerDamage(ply, hitgroup, dmginfo)
    return SUBGAMEMODE:CL_ScalePlayerDamage(ply, hitgroup, dmginfo)
end

function GM:PlayerFootstep()
    return true
end

next_click_sound = 0

local function cs16_main_keybinds(ply, bind, pressed)
    local client = LocalPlayer()
    if pressed then
        local is_spec = ply:IsSpectator()

        -- use sound
        if string.find(bind, "+use") and ply:Alive() and !is_spec then
            timer.Simple(0.1, function()
                if next_click_sound < CurTime() then
                    surface.PlaySound("cstrike/common/wpn_denyselect.wav")
                end
            end)

        -- last weapons
        elseif string.find(bind, "+menu") then
            RunConsoleCommand("lastinv")
            return true

        -- server info
        elseif string.find(bind, "gm_showhelp") then
            current_start_menu = "server_info"
            CreateStartMenu()
            return true
            
        -- choose team
        elseif string.find(bind, "gm_showteam") then
            current_start_menu = "select_team"
            CreateStartMenu()
            return true


        elseif string.find(bind, "+attack2") then
            if is_spec then
                SPECT_SecondaryAttack()
                return true
            end

        elseif string.find(bind, "+attack") then
            -- go to next player
            if is_spec then
                SPECT_PrimaryAttack()
                return true

            -- no shooting at preparing
            elseif game_state == GAMESTATE_PREPARING and SUBGAMEMODE.CONFIG.PREPARING_FREEZE then
                return true
            end
            
        elseif string.find(bind, "+reload") then
            if is_spec then
                SPECT_NextMode()
                return true
            end

        -- overriding spraying
        elseif string.find(bind, "impulse 201") then
            net.Start("cs16_sprayer")
            net.SendToServer()
            return true
        end
    end
end
hook.Add("PlayerBindPress", "hook_cs16_main_keybinds", cs16_main_keybinds)

print("Gamemode loaded cl_overrides.lua")