
GM:SubGamemodeHook_Add("EntityTakeDamage", "CS16_ZM_EntityTakeDamage", function(ply, dmginfo)
    if ply:IsPlayer() and ply:IsZombie() then
        if dmginfo:IsDamageType(DMG_ACID) then
            ply:TakeSafeDamage(25, dmginfo)

        elseif dmginfo:IsDamageType(DMG_BURN) then
            ply:TakeSafeDamage(15, dmginfo)
        end
    end
end)

GM:SubGamemodeHook_Add("PostEntityTakeDamage", "CS16_ZM_PostEntityTakeDamage", function(ply, dmginfo, took)
    if ply:IsPlayer() then
        local attacker = dmginfo:GetAttacker()
        if !IsValid(attacker) or !attacker:IsPlayer() then
            if ply:IsZombie() then
                if dmginfo:IsDamageType(DMG_BURN) then
                    if ply.nextZFireSound < CurTime() then
                        ply:EmitSound(GetCS16Sound("GRENADE_FIRE_PLAYER"))
                        ply.nextZFireSound = CurTime() + 2
                    end
                    ply:StopLastRandomZSound()
                    return
                end
                local snd = "ZOMBIE_PAIN"
                if ply.is_nemesis then
                    snd = "NEMESIS_PAIN"
                end
                ply:EmitSound(GetCS16Sound(snd))
                return
            end
            ply:EmitSound("cstrike/player/bhit_flesh-"..math.random(1,3)..".wav")
        end
    end
end)

-- Player damage sounds
function SUBGAMEMODE:PlayerDamageSounds(ply, hitgroup, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if IsValid(attacker) and attacker:IsPlayer() and SUBGAMEMODE:PlayerShouldTakeDamage(ply, attacker) == false then return true end
    local sound_ent = ply
    if ply.nextDamageZSound > CurTime() then return end
    local dmg_sound = false
    
    if ply:IsZombie() then
        if ply.is_nemesis then
            dmg_sound = GetCS16Sound("NEMESIS_PAIN")
        else
            dmg_sound = GetCS16Sound("ZOMBIE_PAIN")
        end
    else
        dmg_sound = GetCS16Sound("HUMAN_PAIN")
    end

    if isstring(dmg_sound) then
        ply:EmitSound(dmg_sound)
        ply.nextDamageZSound = CurTime() + math.Rand(1,2)
        ply:StopLastRandomZSound()
        ply.nextRandomZSound = CurTime() + 2
    end
end

-- Should player take damage, prevents team damage
function SUBGAMEMODE:PlayerShouldTakeDamage(ply, attacker)
    if game_state != GAMESTATE_ROUND then return false end

    if !IsValid(attacker) or !attacker:IsPlayer() or ply == attacker then return true end
    return (ply:Team() != attacker:Team())
end

-- Player damage scaling
function SUBGAMEMODE:ScalePlayerDamage(ply, hitgroup, dmginfo)
    local attacker = dmginfo:GetAttacker()
    local is_attacker_player = IsValid(attacker) and attacker:IsPlayer()
    local wep = dmginfo:GetInflictor()
    if is_attacker_player and wep == attacker and IsValid(attacker:GetActiveWeapon()) then
        wep = attacker:GetActiveWeapon()
    end
    local dmg_mul = 1

    if is_attacker_player and !GAMEMODE:PlayerShouldTakeDamage(ply, attacker) then
        return true
    end

    if is_attacker_player and CS16_ZM_FiredLastHuman and !attacker:IsZombie() then
        dmg_mul = dmg_mul * 1.25
    end

    -- no knockback when madness
    if ply.zombie_madness_til > CurTime() then
        --dmginfo:SetDamageForce(Vector(0,0,0))
        ply:TakeSafeDamage(dmginfo:GetDamage(), dmginfo)
        dmginfo:SetDamage(0)
        return
    end

    local wep_class = wep:GetClass()

    if IsValid(wep) then
        -- ZOMBIE CLAW ATTACK
        if wep.IsZombieClaws then
            local can_infect = ZM_RoundType().zombies_infect
            local kill_last_human = ZM_RoundType().kill_last_human
            local zombies_claw_damage_mul = ZM_RoundType().zombies_claw_damage_mul

            if ply:IsZombie() then return true end
            if ply:Armor() >= 50 then
                ply:SetArmor(ply:Armor() - 25)
                dmginfo:ScaleDamage(0)
            else
                dmg_mul = 1
                if attacker:IsNemesis() then
                    dmg_mul = dmg_mul * 5
                end
                dmg_mul = dmg_mul * zombies_claw_damage_mul
                if CS16_ZM_FiredLastHuman and kill_last_human then
                    dmginfo:ScaleDamage(dmg_mul)
                    return false
                else
                    if !can_infect then
                        dmginfo:ScaleDamage(dmg_mul)
                    else
                        ply:GotInfected(attacker, false, wep_class)
                    end
                    return false
                end
            end
            return true
        elseif wep_class == "weapon_cs16_knife" then
            dmginfo:ScaleDamage(5)
            return false
        end
    end

    if hitgroup == HITGROUP_HEAD then
        if !ply:GetNWBool("HasHelmet", false) then
            dmg_mul = dmg_mul * 2
        end

    elseif hitgroup == HITGROUP_LEFTARM or hitgroup == HITGROUP_RIGHTARM or hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG then
        dmg_mul = dmg_mul * 0.75
    end

    dmginfo:ScaleDamage(dmg_mul)

    if dmg_mul == 0 then
        return true
    end

    return dmg_mul
end

print("Gamemode loaded gamemodes/zombie_mod/sv_player_damage.lua")