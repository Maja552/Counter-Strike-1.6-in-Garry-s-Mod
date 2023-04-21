
-- Happens every server tick (66 times a second by default)
GM:SubGamemodeHook_Add("Tick", "CS16_ZM_Tick", function()
    if !CS16_ZM_FiredCountDown and game_state == GAMESTATE_PREPARING and (round_state_end - CurTime()) < 10 then
       BroadcastLua('surface.PlaySound("'..SUBGAMEMODE.CONFIG.SOUNDS["COUNTDOWN"]..'")')
       CS16_ZM_FiredCountDown = true
    end

    for k,ply in pairs(player.GetAll()) do
        if ply:IsSpectator() or !ply:Alive() then
            continue
        end

        local ply_is_zombie = ply:IsZombie()

        if ply_is_zombie then
            if !ply.no_idle_sounds and ply.nextRandomZSound < CurTime() and ply.nextZFireSound < CurTime() and ply.zombie_madness_til < CurTime() then
                local snd_tab = ply:GetNextRandomZSound()
                if snd_tab then
                    ply.lastRandomZSound = snd_tab
                    ply.nextRandomZSound = CurTime() + snd_tab.len + math.Rand(4,13)
                    ply.nextDamageZSound = ply.nextDamageZSound + 0.5
                    ply:EmitSound(snd_tab.snd, 75, 100, 0.5)
                end
            end

            if ply.is_radioactive and ply.next_radioactive_attack < CurTime() and ply.frozen_for < CurTime() then
                ply:RadioactiveAttack()
                ply.next_radioactive_attack = CurTime() + math.Rand(0.4, 1)
            end
        end
    end
end)

print("Gamemode loaded gamemodes/zombie_plague/sv_tick.lua")