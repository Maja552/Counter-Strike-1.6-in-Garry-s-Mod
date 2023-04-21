local meta_player = FindMetaTable("Player")

--lua_run Entity(1):PrintInfo()
function meta_player:PrintInfo()
    print("info about "..self:Nick())
    local infos = {
        "Team: "..self:Team(),
        "CS16Team: "..tostring(self:CS16Team()),
    }
    for k,v in pairs(infos) do
        print(v)
    end
end

function meta_player:TakeSafeDamage(amount, dmginfo)
    self:SetHealth(self:Health() - amount)
    if self:Health() < 1 then
        dmginfo:SetDamage(5)
    end
end

function meta_player:RadioactiveAttack()
	local dmginfo = DamageInfo()
	dmginfo:SetDamage(1)
    dmginfo:SetInflictor(self)
	dmginfo:SetAttacker(self)
	dmginfo:SetDamageType(DMG_RADIATION) 

    local ourpos = self:GetPos()
    for k,v in pairs(player.GetAll()) do
        if v:Alive() and v:Team() == TEAM_CT then
            local pos = v:GetPos()
            local dist = pos:Distance(ourpos)
            if dist < 125 then
                v:TakeDamageInfo(dmginfo)
                continue
            end
            local ang = (pos - ourpos):Angle()
            local tr = util.TraceLine({
                start = ourpos + Vector(0,0,50),
                endpos = v:GetPos() + (ang:Forward() * 350),
                mins = Vector(-10, -10, -10),
                maxs = Vector(10, 10, 10),
                filter = function(ent)
                    if ent == self or (ent:GetClass() == "zm_barricade" and ent.BlockInfectGrenade) or (ent:IsPlayer() and (ent:IsSpectator() or !ent:Alive())) then
                        return false
                    end
                    return true
                end
            })
            if tr.Entity == v then
                v:TakeDamageInfo(dmginfo)
            end
        end
    end
end

function meta_player:SetSurvivor()
    self:UnSpectate()
    self:SetTeam(TEAM_CT)
    self:SetHealth(1000)
    self:SetMaxHealth(1000)
    self:SetNWBool("CanBuy", false)
    self:StripWeapons()
    self:Give("weapon_cs16_zm_m249")
    self:ReturnSpentMoney()
    self:SetColor(Color(0,150,255,255))
    self.WasZombie = 0
    self.speed_walking = 260
    self.jump_power = 260
    self.speed_limit_enabled = false
    local nades = 1
    if #player.GetAll() > 10 then
        nades = 2
    end
    local nade_freeze = self:Give("weapon_cs16_zm_freezegrenade")
    local nade_incendiary = self:Give("weapon_cs16_zm_incendiarygrenade")
    if IsValid(nade_freeze) then
        self:GiveAmmo(nades, game.GetAmmoName(nade_freeze:GetPrimaryAmmoType()), false)
    end
    if IsValid(nade_incendiary) then
        self:GiveAmmo(nades, game.GetAmmoName(nade_incendiary:GetPrimaryAmmoType()), false)
    end

    self.nextBeam = CurTime() + 1
end

function meta_player:GotInfected(attacker, mute_infection_sound, inflictor_class)
    self:UnSpectate()
    self:SetZombie(false, mute_infection_sound)
    Notification("left", 2, GetLangRep("NOTICE_INFECT", {{"%s", self:Nick()}}), Color(255,0,0, 255))

    if IsValid(attacker) then
        -- Reward for infecting
        attacker:AddMoney(500, true)

        -- Kill notification
        net.Start("PlayerKilledByPlayer")
            net.WriteEntity(self)
            net.WriteString(inflictor_class)
            net.WriteEntity(attacker)
        net.Broadcast()
    end
end

util.AddNetworkString("cs16_used_antidote")
function meta_player:DoAntidote()
    self:SetHuman()
    self:AfterSetHuman()
    self:SetTeam(TEAM_CT)
    self:StripWeapons()
    self:Give("weapon_cs16_knife")
	self:SetNWBool("CanBuy", true)
    self.WasZombie = -1
    self.is_nemesis = false

    net.Start("cs16_used_antidote")
        net.WriteEntity(self)
    net.Broadcast()

    self:EmitSound(GetCS16Sound("ANTIDOTE"))
    --Notification("left", 4, GetLangRep("NOTICE_ANTIDOTE", {{"%s", self:Nick()}}), cs16_notif_human_color)
end

util.AddNetworkString("cs16_zombie_madness")
function meta_player:DoMadness(cost)
    local ply = self
    ply.zombie_madness_til = CurTime() + SUBGAMEMODE.CONFIG.ZOMBIE_MADNESS_DURATION
    ply:StopLastRandomZSound()
    net.Start("cs16_zombie_madness")
        net.WriteEntity(ply)
        net.WriteInt(SUBGAMEMODE.CONFIG.ZOMBIE_MADNESS_DURATION, 16)
    net.Broadcast()
    
    ply:AddMoney(cost, true)

    BeamPlayer(ply, 250, Color(255,0,0))
    ply:EmitSound(GetCS16Sound("ZOMBIE_MADNESS"))

    return true
end

function meta_player:CreateBarricade(cost, mdl, hp, func)
    if self.barricades_places >= SUBGAMEMODE.CONFIG.MAX_BARRICADES then
        self:OldPrintMessage("You cannot put any more barricades.")
        return false
    end

    local tr = util.TraceLine({
        start = self:EyePos(),
        endpos = self:EyePos() + self:EyeAngles():Forward() * 125,
        filter = self
    })

    if !tr.Hit or self:EyeAngles().pitch < 20 then
        self:OldPrintMessage("You cannot place it here.")
        return false
    end

    for k,v in pairs(ents.FindInSphere(tr.HitPos, 25)) do
        if (v:IsPlayer() and v:Alive() and v:IsZombie()) or v:GetClass() == "zm_barricade" then
            self:OldPrintMessage("You cannot place it here.")
            return false
        end
    end

    local barricade = ents.Create("zm_barricade")
    if IsValid(barricade) then
        barricade:SetModel(mdl)
        barricade:SetPos(tr.HitPos)
        barricade:SetAngles(Angle(0, self:EyeAngles().yaw, 0))
        barricade:SetHealth(hp)
        barricade:Spawn()
        self:AddMoney(cost, true)
        self.barricades_places = self.barricades_places + 1
        if func then
            func(barricade)
        end
        return true, false
    end
    return false
end


util.AddNetworkString("cs16_playerinfected")
util.AddNetworkString("cs16_gotinfected")
function meta_player:SetZombie(first, mute_infection_sound)
    self:UnSpectate()
    SUBGAMEMODE:LastHumanCheck(self)

    self:SetModel("models/player/hl1/zombie.mdl")
    if mute_infection_sound != true then
        self:EmitSound(GetCS16Sound("ZOMBIE_ON_INFECT"), 100, 100, 1)
    end
    local hp = 1800
    if self.is_nemesis then
        self.speed_walking = 325
        self.jump_power = 300
        self.speed_limit_enabled = false
        --self:SetModel("models/player/re/nemesisalpha.mdl")
        hp = hp + 3000 + (math.Clamp(#GAMEMODE:GetPlayers() - 1, 1, 10) * 500)
    else
        hp = hp + (math.Clamp(#GAMEMODE:GetPlayers() - 1, 1, 8) * 175)
        if first then
            hp = hp * ZM_RoundType().first_zombie_hp_mul
        end
    end
    self:SetHealth(hp)
    self:SetMaxHealth(hp)

    self:SetWalkSpeed(260)
    self:SetRunSpeed(260)
	self:SetCrouchedWalkSpeed(0.37)
    self:SetCrouchedWalkSpeed(0.3)
    self:SetArmor(0)
    self:SetNWBool("HasNVG", false)
	self:SetNWBool("HasSilentBoots", false)
    
    self.is_radioactive = false
    self.speed_walking = SUBGAMEMODE.CONFIG.DEFAULT_WALK_SPEED
    self.jump_power = SUBGAMEMODE.CONFIG.DEFAULT_JUMP_POWER
    self.speed_limit_enabled = true


    if isstring(self.cs16_class) and ZM_RoundType().zombie_classes_work then
        local class_tab = SUBGAMEMODE.CONFIG.CLASSES[self.cs16_class]
        if class_tab then
            class_tab.on_zombie_set(self)
            --print("spawned with class: "..self.cs16_class)
        end
    end

    if !first then
        self:DropAllWeapons()
    end
    self:StripWeapons()
    self:Give("weapon_cs16_zm_zombie")

    self:SetTeam(TEAM_T)
    self:AllowFlashlight(false)

    self.nextDamageZSound = CurTime() + 1
    self.nextRandomZSound = CurTime() + 4
    self.no_idle_sounds = false

    net.Start("cs16_gotinfected")
    net.Send(self)

    net.Start("cs16_playerinfected")
        net.WriteEntity(self)
        net.WriteBool(self.is_nemesis)
    net.Broadcast()

    self.zombie_lives = self.zombie_lives - 1
end

function meta_player:ReturnSpentMoney()
    print("returning "..self.zm_spent.."$ for "..self:Nick())
    if self.zm_spent > 0 then
        self:ChatPrint("Returned "..self.zm_spent.."$")
        self:AddMoney(self.zm_spent, true)
    end
    self.zm_spent = 0
end

function meta_player:StopLastRandomZSound()
    if istable(self.lastRandomZSound) then
        self:StopSound(self.lastRandomZSound.snd)
    end
end

function meta_player:GetNextRandomZSound()
    local random_zombie_sounds = SUBGAMEMODE.CONFIG.SOUNDS["ZOMBIE_IDLE"]
    if !self.lastRandomZSound then
        return random_zombie_sounds[math.random(#random_zombie_sounds)]
    end

    local all_possible_z_sounds = {}
    for k,v in pairs(random_zombie_sounds) do
        if v != self.lastRandomZSound then
            table.ForceInsert(all_possible_z_sounds, v)
        end
    end
    local rnd_snd = all_possible_z_sounds[math.random(#all_possible_z_sounds)]
    rnd_snd.next_clear = CurTime() + rnd_snd.len
    if rnd_snd then
        return rnd_snd
    end
end

print("Gamemode loaded gamemodes/zombie_mod/sv_player_ext.lua")