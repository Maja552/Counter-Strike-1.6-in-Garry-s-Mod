
CS16_ZM_ROUNDTYPES = {
    default = {
        allow_zombie_spawning = true,
        zombies_infect = true,
        zombies_claw_damage_mul = 1,
        last_human_enabled = true,
        kill_last_human = true,
        min_players = 0,
        first_zombie_hp_mul = 1.3,
        beam_survivors = false,
        beam_nemesis = false,
        zombie_buymenu_enabled = true,
        zombie_classes_work = true,
        sv_post_round_start = function()
            local all_players = GAMEMODE:GetPlayers()
            local all_possible_zombies = {}
            for k,v in pairs(all_players) do
                if v:Alive() and !v:IsSpectator() then
                    v:SetTeam(TEAM_CT)
                    v.is_nemesis = false
                    table.ForceInsert(all_possible_zombies, v)
                end
            end

            local patient_zero = all_possible_zombies[math.random(#all_possible_zombies)]
            Notification("upper", 2, GetLangRep("NOTICE_FIRST", {{"%s", patient_zero:Nick()}}), Color(255,0,0, 200))
            patient_zero.is_nemesis = false
            patient_zero:SetZombie(true, false)

            --patient_zero:ReturnSpentMoney()
        end,
        cl_post_round_start = function()
        end
    },
end

print("Gamemode loaded gamemodes/zombie_plague/sh_roundtypes.lua")