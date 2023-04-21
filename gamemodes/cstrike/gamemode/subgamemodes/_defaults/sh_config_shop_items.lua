
GM.DEFAULT_CONFIG.CS16_PRICES = { 
    weapon_cs16_glock18 = 400,
    weapon_cs16_usp = 500,
    weapon_cs16_p228 = 600,
    weapon_cs16_deagle = 650,
    weapon_cs16_fiveseven = 700,
    weapon_cs16_elite = 800,

    weapon_cs16_mac10 = 1250,
    weapon_cs16_tmp = 1400,
    weapon_cs16_mp5navy = 1550,
    weapon_cs16_ump45 = 1700,
    weapon_cs16_p90 = 2250,

    weapon_cs16_m3 = 3000,
    weapon_cs16_xm1014 = 3750,

    weapon_cs16_galil = 2000,
    weapon_cs16_famas = 2300,
    weapon_cs16_ak47 = 2800,
    weapon_cs16_m4a1 = 3100,
    weapon_cs16_aug = 3500,
    weapon_cs16_sg552 = 3700,

    weapon_cs16_scout = 2250,
    weapon_cs16_g3sg1 = 4200,
    weapon_cs16_awp = 4750,
    weapon_cs16_sg550 = 5000,
    
    weapon_cs16_m249 = 4000,

    kevlar = 650,
    helmet = 350,
    defuse_kit = 200,
    weapon_cs16_flashbang = 200,
    weapon_cs16_hegrenade = 300,
    weapon_cs16_smokegrenade = 300,
    nvg = 500,

    flashlight = 100,

    primary_ammo = 0,
    secondary_ammo = 0
}

GM.DEFAULT_CONFIG.CS16_SHOP_ITEMS = {
    {"weapon_cs16_glock18"},
    {"weapon_cs16_usp"},
    {"weapon_cs16_p228"},
    {"weapon_cs16_deagle"},
    {"weapon_cs16_fiveseven"},
    {"weapon_cs16_elite"},

    {"weapon_cs16_tmp"},
    {"weapon_cs16_mac10"},
    {"weapon_cs16_mp5navy"},
    {"weapon_cs16_ump45"},
    {"weapon_cs16_p90"},

    {"weapon_cs16_famas"},
    {"weapon_cs16_ak47"},
    {"weapon_cs16_m4a1"},
    {"weapon_cs16_galil"},
    {"weapon_cs16_sg552"},
    {"weapon_cs16_aug"},

    {"weapon_cs16_scout"},
    {"weapon_cs16_awp"},
    {"weapon_cs16_sg550"},
    {"weapon_cs16_g3sg1"},

    {"weapon_cs16_m249"},

    {"weapon_cs16_m3"},
    {"weapon_cs16_xm1014"},

    {"weapon_cs16_hegrenade", function(ply, name, cost)
        return ply:BuyCS16Grenade(name, "CS16_HEGRENADE", cost)
    end},
    {"weapon_cs16_smokegrenade", function(ply, name, cost)
        return ply:BuyCS16Grenade(name, "CS16_SMOKEGRENADE", cost)
    end},
    {"weapon_cs16_flashbang", function(ply, name, cost)
        return ply:BuyCS16Grenade(name, "CS16_FLASHBANG", cost)
    end},

    {"kevlar", function(ply, name, cost)
        if ply:Armor() < 80 then
            ply:SetArmor(100)
            ply:AddMoney(cost, true)
            ply:EmitSound("items/kevlar_pickup.wav")
            return true
        else
            ply:OldPrintMessage("You already have kevlar!")
        end
        return false
    end},
    {"kevlar_helmet", function(ply, name)
        local has_helmet = ply:GetNWBool("HasHelmet", false)
        if ply:Armor() > 80 and has_helmet then
            ply:OldPrintMessage("You already have that equipment")
            return false
        end
        local cost_kevlar = SUBGAMEMODE.CONFIG.CS16_PRICES.kevlar
        local cost_helmet = SUBGAMEMODE.CONFIG.CS16_PRICES.helmet
        local bought_armor = false
        if ply:Armor() < 80 then
            if (!has_helmet and cost_kevlar + cost_helmet > ply.cs16_money) or cost_kevlar > ply.cs16_money then
                ply:OldPrintMessage("You have insufficient funds!")
                return false
            end
            ply:SetArmor(100)
            ply:AddMoney(-cost_kevlar, true)
            ply:EmitSound("items/kevlar_pickup.wav")
            bought_armor = true
        end
        if has_helmet == false then
            if cost_helmet > ply.cs16_money then
                ply:OldPrintMessage("You have insufficient funds!")
                return false
            end
            ply:SetNWBool("HasHelmet", true)
            ply:AddMoney(-cost_helmet, true)
            if !bought_armor then
                ply:EmitSound("items/kevlar_pickup.wav")
            end
            return true
        end
    end},
    {"nvg", function(ply, name, cost)
        if ply:GetNWBool("HasNVG", false) == false then
            ply:SetNWBool("HasNVG", true)
            ply:AddMoney(cost, true)
            return true
        else
            ply:OldPrintMessage("You already have that equipment")
        end
        return false
    end},
    {"primary_ammo", function(ply)
        return ply:BuyCS16Ammo(0)
    end},
    {"secondary_ammo", function(ply)
        return ply:BuyCS16Ammo(1)
    end},
}

print("Gamemode loaded gamemodes/_defaults/sh_config_shop_items.lua")