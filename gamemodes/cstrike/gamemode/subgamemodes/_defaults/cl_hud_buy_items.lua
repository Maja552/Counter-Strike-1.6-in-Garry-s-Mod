
local price_tab = GM.DEFAULT_CONFIG.CS16_PRICES

local buy_menu_pages = {
    [TEAM_T] = {
        main = {
            page_name = "Buy Item",
            buymenu_height = 14 * 24,
            buttons = {
                {"Handgun", "open_page", "handguns"},
                {"Shotgun", "open_page", "shotguns"},
                {"Sub-Machine Gun", "open_page", "submachine_guns"},
                {"Rifle", "open_page", "rifles"},
                {"Machine Gun", "open_page", "machine_guns"},
                true,
                {"Primary weapon ammo", "buy", "primary_ammo"},
                {"Secondary weapon ammo", "buy", "secondary_ammo"},
                true,
                {"Equipment", "open_page", "equipment"},
            }
        },
        
        handguns = {
            page_name = "Buy a Handgun",
            buttons = {
                {{"9X19mm Sidearm", price_tab["weapon_cs16_glock18"].."$"}, "buy", "weapon_cs16_glock18"},
                {{"K&M .45 Tactical", price_tab["weapon_cs16_usp"].."$"}, "buy", "weapon_cs16_usp"},
                {{"228 Compact", price_tab["weapon_cs16_p228"].."$"}, "buy", "weapon_cs16_p228"},
                {{"Night Hawk .50C", price_tab["weapon_cs16_deagle"].."$"}, "buy", "weapon_cs16_deagle"},
                {{".40 Dual Elites", price_tab["weapon_cs16_elite"].."$"}, "buy", "weapon_cs16_elite"},
            }
        },
        
        submachine_guns = {
            page_name = "Buy a Sub-Machine Gun",
            buttons = {
                {{"Ingram MAC-10", price_tab["weapon_cs16_mac10"].."$"}, "buy", "weapon_cs16_mac10"},
                {{"K&M Sub-Machine Gun", price_tab["weapon_cs16_mp5navy"].."$"}, "buy", "weapon_cs16_mp5navy"},
                {{"K&M UMP45", price_tab["weapon_cs16_ump45"].."$"}, "buy", "weapon_cs16_ump45"},
                {{"ES C90", price_tab["weapon_cs16_p90"].."$"}, "buy", "weapon_cs16_p90"},
            }
        },
        
        shotguns = {
            page_name = "Buy a Shotgun",
            buttons = {
                {{"Leone 12 Gauge Super", price_tab["weapon_cs16_m3"].."$"}, "buy", "weapon_cs16_m3"},
                {{"Leone YG1265 Auto Shotgun", price_tab["weapon_cs16_xm1014"].."$"}, "buy", "weapon_cs16_xm1014"},
            }
        },
        
        rifles = {
            page_name = "Buy a Rifle",
            buttons = {
                {{"IDF Defender", price_tab["weapon_cs16_galil"].."$"}, "buy", "weapon_cs16_galil"},
                {{"Shmidt Scout", price_tab["weapon_cs16_scout"].."$"}, "buy", "weapon_cs16_scout"},
                {{"CV-47", price_tab["weapon_cs16_ak47"].."$"}, "buy", "weapon_cs16_ak47"},
                {{"Krieg 552 Commando", price_tab["weapon_cs16_sg552"].."$"}, "buy", "weapon_cs16_sg552"},
                {{"Magnum Sniper Rifle", price_tab["weapon_cs16_awp"].."$"}, "buy", "weapon_cs16_awp"},
                {{"D3/AU-1 Semi-Auto Sniper Rifle", price_tab["weapon_cs16_g3sg1"].."$"}, "buy", "weapon_cs16_g3sg1"},
            }
        },
        
        machine_guns = {
            page_name = "Buy a Machine Gun",
            buttons = {
                {{"ES M249 Para", price_tab["weapon_cs16_m249"].."$"}, "buy", "weapon_cs16_m249"},
            }
        },
        
        equipment = {
            page_name = "Buy Equipment",
            buttons = {
                {{"Kevlar Vest", price_tab["kevlar"].."$"}, "buy", "kevlar"},
                {{"Kevlar Vest & Helmet", price_tab["kevlar"] + price_tab["helmet"].."$"}, "buy", "kevlar_helmet"},
                {{"Flashbang", price_tab["weapon_cs16_flashbang"].."$"}, "buy", "weapon_cs16_flashbang"},
                {{"HE Grenade", price_tab["weapon_cs16_hegrenade"].."$"}, "buy", "weapon_cs16_hegrenade"},
                {{"Smoke Grenade", price_tab["weapon_cs16_smokegrenade"].."$"}, "buy", "weapon_cs16_smokegrenade"},
                {{"NightVision Goggles", price_tab["nvg"].."$"}, "buy", "nvg"},
            }
        }
    },
    [TEAM_CT] = {
        main = {
            page_name = "Buy Item",
            buymenu_height = 14 * 24,
            buttons = {
                {"Handgun", "open_page", "handguns"},
                {"Shotgun", "open_page", "shotguns"},
                {"Sub-Machine Gun", "open_page", "submachine_guns"},
                {"Rifle", "open_page", "rifles"},
                {"Machine Gun", "open_page", "machine_guns"},
                true,
                {"Primary weapon ammo", "buy", "primary_ammo"},
                {"Secondary weapon ammo", "buy", "secondary_ammo"},
                true,
                {"Equipment", "open_page", "equipment"},
            }
        },
        
        handguns = {
            page_name = "Buy a Handgun",
            buttons = {
                {{"9X19mm Sidearm", price_tab["weapon_cs16_glock18"].."$"}, "buy", "weapon_cs16_glock18"},
                {{"K&M .45 Tactical", price_tab["weapon_cs16_usp"].."$"}, "buy", "weapon_cs16_usp"},
                {{"228 Compact", price_tab["weapon_cs16_p228"].."$"}, "buy", "weapon_cs16_p228"},
                {{"Night Hawk .50C", price_tab["weapon_cs16_deagle"].."$"}, "buy", "weapon_cs16_deagle"},
                {{"ES Five-Seven", price_tab["weapon_cs16_fiveseven"].."$"}, "buy", "weapon_cs16_fiveseven"},
            }
        },
        
        submachine_guns = {
            page_name = "Buy a Sub-Machine Gun",
            buttons = {
                {{"Schmidt Machine Pistol", price_tab["weapon_cs16_tmp"].."$"}, "buy", "weapon_cs16_tmp"},
                {{"K&M Sub-Machine Gun", price_tab["weapon_cs16_mp5navy"].."$"}, "buy", "weapon_cs16_mp5navy"},
                {{"K&M UMP45", price_tab["weapon_cs16_ump45"].."$"}, "buy", "weapon_cs16_ump45"},
                {{"ES C90", price_tab["weapon_cs16_p90"].."$"}, "buy", "weapon_cs16_p90"},
            }
        },
        
        shotguns = {
            page_name = "Buy a Shotgun",
            buttons = {
                {{"Leone 12 Gauge Super", price_tab["weapon_cs16_m3"].."$"}, "buy", "weapon_cs16_m3"},
                {{"Leone YG1265 Auto Shotgun", price_tab["weapon_cs16_xm1014"].."$"}, "buy", "weapon_cs16_xm1014"},
            }
        },
        
        rifles = {
            page_name = "Buy a Rifle",
            buttons = {
                {{"Clarion 5.56", price_tab["weapon_cs16_famas"].."$"}, "buy", "weapon_cs16_famas"},
                {{"Shmidt Scout", price_tab["weapon_cs16_scout"].."$"}, "buy", "weapon_cs16_scout"},
                {{"Maverick M4A1 Carbine", price_tab["weapon_cs16_m4a1"].."$"}, "buy", "weapon_cs16_m4a1"},
                {{"Bullpup", price_tab["weapon_cs16_aug"].."$"}, "buy", "weapon_cs16_aug"},
                {{"Magnum Sniper Rifle", price_tab["weapon_cs16_awp"].."$"}, "buy", "weapon_cs16_awp"},
                {{"Krieg 550 Commando", price_tab["weapon_cs16_sg550"].."$"}, "buy", "weapon_cs16_sg550"},
            }
        },
        
        machine_guns = {
            page_name = "Buy a Machine Gun",
            buttons = {
                {{"ES M249 Para", price_tab["weapon_cs16_m249"].."$"}, "buy", "weapon_cs16_m249"},
            }
        },
        
        equipment = {
            page_name = "Buy Equipment",
            buttons = {
                {{"Kevlar Vest", price_tab["kevlar"].."$"}, "buy", "kevlar"},
                {{"Kevlar Vest & Helmet", price_tab["kevlar"] + price_tab["helmet"].."$"}, "buy", "kevlar_helmet"},
                {{"Flashbang", price_tab["weapon_cs16_flashbang"].."$"}, "buy", "weapon_cs16_flashbang"},
                {{"HE Grenade", price_tab["weapon_cs16_hegrenade"].."$"}, "buy", "weapon_cs16_hegrenade"},
                {{"Smoke Grenade", price_tab["weapon_cs16_smokegrenade"].."$"}, "buy", "weapon_cs16_smokegrenade"},
                {{"NightVision Goggles", price_tab["nvg"].."$"}, "buy", "nvg"},
                {{"Defuse Kit", price_tab["defuse_kit"].."$"}, "buy", "defuse_kit"},
            }
        }
    }
}

function GM.DEFAULT_MENU_GetBuyMenuPages()
    return buy_menu_pages[LocalPlayer():Team()]
end

print("Gamemode loaded gamemodes/_defaults/cl_hud_buy_items.lua")