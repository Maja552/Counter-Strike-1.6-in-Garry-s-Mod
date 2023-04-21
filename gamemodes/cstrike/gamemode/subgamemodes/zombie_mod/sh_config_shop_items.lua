
SUBGAMEMODE.CONFIG.CS16_PRICES = { 
    weapon_cs16_glock18 = 250,
    weapon_cs16_usp = 250,
    weapon_cs16_p228 = 500,
    weapon_cs16_deagle = 500,
    weapon_cs16_fiveseven = 500,
    weapon_cs16_elite = 750,

    weapon_cs16_mac10 = 1000,
    weapon_cs16_tmp = 1000,
    weapon_cs16_mp5navy = 1250,
    weapon_cs16_ump45 = 1250,
    weapon_cs16_p90 = 1750,

    weapon_cs16_m3 = 2250,
    weapon_cs16_xm1014 = 3750,

    weapon_cs16_galil = 2250,
    weapon_cs16_famas = 2250,
    weapon_cs16_ak47 = 3500,
    weapon_cs16_m4a1 = 3500,
    weapon_cs16_zm_aug = 4000,
    weapon_cs16_zm_sg552 = 4000,

    weapon_cs16_scout = 2000,
    weapon_cs16_awp = 4000,

    weapon_cs16_zm_goldendeagle = 2000,
    weapon_cs16_sg550 = 6000,
    weapon_cs16_g3sg1 = 6000,
    weapon_cs16_m249 = 7000,
    weapon_cs16_zm_m249 = 9000,

    weapon_cs16_zm_freezegrenade = 750,
    weapon_cs16_zm_incendiarygrenade = 750,
    weapon_cs16_zm_lightgrenade = 500,
    kevlar = 2000,
    silent_boots = 2000,
    cloak = 2000,
    nvg = 2000,
    teleport_to_spawn = 3000,

    barricade_cardboard = 1250,
    barricade_barrier = 2500,
    barricade_cross = 4000,

    shut_up = 2000,
    human_model = 2000,
    madness = 3000,
    antidote = 4500,
    weapon_cs16_zm_infectgrenade = 5000,
}

SUBGAMEMODE.CONFIG.CS16_SHOP_ITEMS = {
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
    {"weapon_cs16_zm_sg552"},
    {"weapon_cs16_zm_aug"},

    {"weapon_cs16_scout"},
    {"weapon_cs16_awp"},
    {"weapon_cs16_sg550"},
    {"weapon_cs16_g3sg1"},

    {"weapon_cs16_m249"},

    {"weapon_cs16_m3"},
    {"weapon_cs16_xm1014"},

    {"weapon_cs16_zm_incendiarygrenade", function(ply, name, cost)
        return ply:BuyCS16Grenade(name, "CS16_HEGRENADE", cost)
    end},
    {"weapon_cs16_zm_lightgrenade", function(ply, name, cost)
        return ply:BuyCS16Grenade(name, "CS16_SMOKEGRENADE", cost)
    end},
    {"weapon_cs16_zm_freezegrenade", function(ply, name, cost)
        return ply:BuyCS16Grenade(name, "CS16_FLASHBANG", cost)
    end},

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
    {"nvg", function(ply, name, cost)
        if ply:GetNWBool("HasNVG", false) == false then
            ply:SetNWBool("HasNVG", true)
            ply:AddMoney(cost, true)
            ply:EmitSound("items/kevlar_pickup.wav")
            return true
        else
            ply:OldPrintMessage("You already have that equipment")
        end
        return false
    end},
    {"silent_boots", function(ply, name, cost)
        if ply:GetNWBool("HasSilentBoots", false) == false then
            ply:SetNWBool("HasSilentBoots", true)
            ply:AddMoney(cost, true)
            ply:EmitSound("items/kevlar_pickup.wav")
            return true
        else
            ply:OldPrintMessage("You already have that equipment")
        end
        return false
    end},
    {"cloak", function(ply, name, cost)
        if game_state != GAMESTATE_ROUND then
            ply:OldPrintMessage("You cannot buy this item now")
            return false
        end
        if ply.cloaked_til < CurTime() then
            ply:CloakTil(10)
            BeamPlayer(ply, 1000, Color(255,255,255))
            ply:AddMoney(cost, true)
            ply:EmitSound("weapons/flashbang-1.wav")
            return true
        else
            ply:OldPrintMessage("You already have that equipment")
        end
        return false
    end},
    {"antidote", function(ply, name, cost)
        if game_state != GAMESTATE_ROUND then
            ply:OldPrintMessage("You cannot buy this item now")
            return false
        end
        if ply:IsZombie() then
            local numzomb = team.NumPlayers(TEAM_T)
            if numzomb < 2 or (numzomb < 3 and #player.GetAll() > 4) then
                ply:OldPrintMessage("Too few alive players to buy that")
                return false
            end
            BeamPlayer(ply, 500, Color(0,0,255))
            ply:DoAntidote()
            ply:AddMoney(cost, true)
            return true
        end
        return false
    end},
    {"teleport_to_spawn", function(ply, name, cost)
        if game_state != GAMESTATE_ROUND then
            ply:OldPrintMessage("You cannot buy this item now")
            return false
        end
        local spawn_point = GAMEMODE:GetRandomAfterSpawnpoint(ply)
        if IsValid(spawn_point) then
            ply:SetPos(spawn_point:GetPos())
            ply:EmitSound("weapons/flashbang-1.wav")
            ply:AddMoney(cost, true)
            return true
        end
        return false
    end},
    {"barricade_cross", function(ply, name, cost)
        return ply:CreateBarricade(cost, "models/props/xenprops1/cross.mdl", 500, function(ent)
            ent:SetPos(ent:GetPos() + Vector(0,0,15))
	        ent:SetModelScale(0.75, 0)
        end)
    end},
    {"barricade_barrier", function(ply, name, cost)
        return ply:CreateBarricade(cost, "models/props/hazardous/barrier.mdl", 250, function(ent)
            ent:SetPos(ent:GetPos() + Vector(0,0,15))
	        ent:SetModelScale(0.75, 0)
        end)
    end},
    {"barricade_cardboard", function(ply, name, cost)
        return ply:CreateBarricade(cost, "models/props/fifties/cardboard_white.mdl", 50, function(ent)
            ent:SetPos(ent:GetPos() + Vector(0,0,15))
            ent.BlockInfectGrenade = true
            ent:SetMaterial("models/props_combine/stasisshield_sheet")
        end)
    end},
    {"madness", function(ply, name, cost)
        if ply:IsZombie() and ply.zombie_madness_til < CurTime() then
            return ply:DoMadness(cost)
        end
        return false
    end},
    {"shut_up", function(ply, name, cost)
        if ply:IsZombie() then
            ply.no_idle_sounds = true
            ply:StopLastRandomZSound()
            ply:AddMoney(cost, true)
            return true
        end
        return false
    end},
    {"human_model", function(ply, name, cost)
        if ply:IsZombie() then
            GAMEMODE:PlayerSetModel(ply)
            ply:StripWeapon("weapon_cs16_zm_zombie")
            ply:Give("weapon_cs16_zm_zombie_stealth")
            ply:AddMoney(cost, true)
            return true
        end
        return false
    end},
    {"weapon_cs16_zm_infectgrenade", function(ply, name, cost)
        return ply:BuyCS16Grenade(name, "CS16_HEGRENADE", cost)
    end},
    {"weapon_cs16_zm_goldendeagle"},
    {"weapon_cs16_zm_m249"}
}

print("Gamemode loaded gamemodes/zombie_mod/sh_config_shop_items.lua")