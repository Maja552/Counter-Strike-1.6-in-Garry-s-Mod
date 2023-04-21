
local price_tab = SUBGAMEMODE.CONFIG.CS16_PRICES

local buy_menu_pages = {
    [TEAM_CT] = {
        main = {
            page_name = "Buy Item",
            buymenu_height = 15 * 24,
            buttons = {
                {"Handgun", "open_page", "handguns"},
                {"Shotgun", "open_page", "shotguns"},
                {"Sub-Machine Gun", "open_page", "submachine_guns"},
                {"Rifle", "open_page", "rifles"},
                {"Special Guns", "open_page", "special"},
                true,
                {"Equipment", "open_page", "equipment"},
                {"Barricades", "open_page", "barricades"}
            }
        },
        
        handguns = {
            page_name = "Buy a Handgun",
            buttons = {
                {{"9X19mm Sidearm", price_tab["weapon_cs16_glock18"].."$"}, "buy", "weapon_cs16_glock18"},
                {{"K&M .45 Tactical", price_tab["weapon_cs16_usp"].."$"}, "buy", "weapon_cs16_usp"},
                true,
                {{"228 Compact", price_tab["weapon_cs16_p228"].."$"}, "buy", "weapon_cs16_p228"},
                {{"Night Hawk .50C", price_tab["weapon_cs16_deagle"].."$"}, "buy", "weapon_cs16_deagle"},
                {{"ES Five-Seven", price_tab["weapon_cs16_fiveseven"].."$"}, "buy", "weapon_cs16_fiveseven"},
                true,
                {{".40 Dual Elites", price_tab["weapon_cs16_elite"].."$"}, "buy", "weapon_cs16_elite"}
            }
        },
        
        submachine_guns = {
            page_name = "Buy a Sub-Machine Gun",
            buttons = {
                {{"Schmidt Machine Pistol", price_tab["weapon_cs16_tmp"].."$"}, "buy", "weapon_cs16_tmp"},
                {{"Ingram MAC-10", price_tab["weapon_cs16_mac10"].."$"}, "buy", "weapon_cs16_mac10"},
                {{"K&M Sub-Machine Gun", price_tab["weapon_cs16_mp5navy"].."$"}, "buy", "weapon_cs16_mp5navy"},
                {{"K&M UMP45", price_tab["weapon_cs16_ump45"].."$"}, "buy", "weapon_cs16_ump45"},
                {{"ES C90", price_tab["weapon_cs16_p90"].."$"}, "buy", "weapon_cs16_p90"}
            }
        },
        
        shotguns = {
            page_name = "Buy a Shotgun",
            buttons = {
                {{"Leone 12 Gauge Super", price_tab["weapon_cs16_m3"].."$"}, "buy", "weapon_cs16_m3"},
                {{"Leone YG1265 Auto Shotgun", price_tab["weapon_cs16_xm1014"].."$"}, "buy", "weapon_cs16_xm1014"}
            }
        },
        
        rifles = {
            page_name = "Buy a Rifle",
            buttons = {
                {{"IDF Defender", price_tab["weapon_cs16_galil"].."$"}, "buy", "weapon_cs16_galil"},
                {{"Clarion 5.56", price_tab["weapon_cs16_famas"].."$"}, "buy", "weapon_cs16_famas"},
                --{{"Shmidt Scout", price_tab["weapon_cs16_scout"].."$"}, "buy", "weapon_cs16_scout"},
                true,
                {{"Maverick M4A1 Carbine", price_tab["weapon_cs16_m4a1"].."$"}, "buy", "weapon_cs16_m4a1"},
                {{"CV-47", price_tab["weapon_cs16_ak47"].."$"}, "buy", "weapon_cs16_ak47"},
                true,
                {{"Krieg 552 Commando", price_tab["weapon_cs16_zm_sg552"].."$"}, "buy", "weapon_cs16_zm_sg552"},
                {{"Bullpup", price_tab["weapon_cs16_zm_aug"].."$"}, "buy", "weapon_cs16_zm_aug"},
                {{"Magnum Sniper Rifle", price_tab["weapon_cs16_awp"].."$"}, "buy", "weapon_cs16_awp"}
            }
        },
        
        special = {
            page_name = "Buy a Special Gun",
            buttons = {
                {{"Golden Night Hawk .50C", price_tab["weapon_cs16_zm_goldendeagle"].."$"}, "buy", "weapon_cs16_zm_goldendeagle"},
                {{"Krieg 550 Commando", price_tab["weapon_cs16_sg550"].."$"}, "buy", "weapon_cs16_sg550"},
                {{"D3/AU-1 Semi-Auto Sniper Rifle", price_tab["weapon_cs16_g3sg1"].."$"}, "buy", "weapon_cs16_g3sg1"},
                {{"ES M249 Para", price_tab["weapon_cs16_m249"].."$"}, "buy", "weapon_cs16_m249"},
                --{{"Survivor's M249", price_tab["weapon_cs16_zm_m249"].."$"}, "buy", "weapon_cs16_zm_m249"}
            }
        },
        
        equipment = {
            page_name = "Buy Equipment",
            buttons = {
                {{"Light Grenade", price_tab["weapon_cs16_zm_lightgrenade"].."$"}, "buy", "weapon_cs16_zm_lightgrenade"},
                {{"Frost Grenade", price_tab["weapon_cs16_zm_freezegrenade"].."$"}, "buy", "weapon_cs16_zm_freezegrenade"},
                {{"Incendiary Grenade", price_tab["weapon_cs16_zm_incendiarygrenade"].."$"}, "buy", "weapon_cs16_zm_incendiarygrenade"},
                true,
                {{"Kevlar Vest", price_tab["kevlar"].."$"}, "buy", "kevlar"},
                {{"Silent Boots", price_tab["silent_boots"].."$"}, "buy", "silent_boots"},
                {{"Cloak", price_tab["cloak"].."$"}, "buy", "cloak"},
                {{"NightVision Goggles", price_tab["nvg"].."$"}, "buy", "nvg"},
                {{"Teleport to spawn", price_tab["teleport_to_spawn"].."$"}, "buy", "teleport_to_spawn"},
            }
        },
        barricades = {
            page_name = "Buy a Barricade",
            buttons = {
                {{"Wall (50 HP)", price_tab["barricade_cardboard"].."$"}, "buy", "barricade_cardboard"},
                {{"Barrier (250 HP)", price_tab["barricade_barrier"].."$"}, "buy", "barricade_barrier"},
                {{"Cross (500 HP)", price_tab["barricade_cross"].."$"}, "buy", "barricade_cross"},
            }
        },
    },
    [TEAM_T] = {
        main = {
            page_name = "Zombie Menu",
            buymenu_height = 15 * 24,
            buttons = {
                {"Buy Extra Items/Abilities", "open_page", "buy_items"},
                {"Choose Zombie Class", "open_page", "choose_class"},
            },
        },
        buy_items = {
            page_name = "Buy Extra Items/Abilities",
            buttons = {
                {{"Shut up", price_tab["shut_up"].."$"}, "buy", "shut_up"},
                {{"Stealth Human Suit", price_tab["human_model"].."$"}, "buy", "human_model"},
                {{"Zombie Madness", price_tab["madness"].."$"}, "buy", "madness"},
                {{"T-Virus Antidote", price_tab["antidote"].."$"}, "buy", "antidote"},
                {{"Infection Bomb", price_tab["weapon_cs16_zm_infectgrenade"].."$"}, "buy", "weapon_cs16_zm_infectgrenade"},
            }
        },
        choose_class = {
            page_name = "Choose a class",
            buttons = {
                {"Balanced Zombie", "choose_class", "zm_balanced"},
                true,
                {{"Fast Zombie", "Health: 90%", "Speed: 120%"}, "choose_class", "zm_speed"},
                {{"Jumper Zombie", "Health: 90%", "JumpPower: 150%"}, "choose_class", "zm_jump"},
                {{"Tough Zombie", "Health: 120%", "Speed: 85%"}, "choose_class", "zm_hp"},
                {{"Radioactive Zombie", "Health: 85%", "Irradiates Humans"}, "choose_class", "zm_radioactive"},
            }
        }
    }
}

function SUBGAMEMODE:MENU_GetBuyMenuPages()
    local client = LocalPlayer()
    if game_state == GAMESTATE_PREPARING then
        return buy_menu_pages[TEAM_CT]
    end
    if (!ZM_RoundType().zombie_buymenu_enabled and client:Team() == TEAM_T) or game_state == GAMESTATE_POSTROUND then
        return nil
    end
    return buy_menu_pages[client:Team()]
end

print("Gamemode loaded gamemodes/zombie_mod/cl_hud_buy_items.lua")