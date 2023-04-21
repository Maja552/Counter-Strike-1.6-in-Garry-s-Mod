local meta_player = FindMetaTable("Player")

util.AddNetworkString("cs16_gotinfected")
util.AddNetworkString("cs16_playerinfected")

function meta_player:SetDefaultVariables()
    self.nextDamageZSound = 0
    self.nextRandomZSound = 0
    self.nextZFireSound = 0
    self.zombie_lives = 0
    self.zombie_madness_til = 0
    self.nextBeam = 0
    self.WasZombie = 0
    self.no_idle_sounds = false
    self.barricades_places = 0
    self.is_radioactive = false
    self.next_radioactive_attack = 0
end

function meta_player:Infect(infecter)
    self:SetTeam(TEAM_T)

    local adjusted_hp = 3000 + (math.Clamp(#GAMEMODE:GetPlayers() - 1, 1, 10) * 500)
    self:SetHealth(adjusted_hp)
    self:SetMaxHealth(adjusted_hp)
    self:SetModel("models/player/hl1/zombie.mdl")

    self.speed_walking = SUBGAMEMODE.CONFIG.DEFAULT_WALK_SPEED
    self.jump_power = SUBGAMEMODE.CONFIG.DEFAULT_JUMP_POWER
    self.speed_limit_enabled = true

    self:SetWalkSpeed(260)
    self:SetRunSpeed(260)
	self:SetCrouchedWalkSpeed(0.37)
    self:SetCrouchedWalkSpeed(0.3)
    self:SetArmor(0)
    self:SetNWBool("HasNVG", false)
	self:SetNWBool("HasSilentBoots", false)

    self:EmitSound(GetCS16Sound("ZOMBIE_ON_INFECT"), 100, 100, 1)
    self:AllowFlashlight(false)

    self:StripWeapons()
    self:Give("weapon_cs16_zm_zombie")

    self.nextDamageZSound = CurTime() + 1
    self.nextRandomZSound = CurTime() + 4
    self.no_idle_sounds = false

    net.Start("cs16_gotinfected")
    net.Send(self)

    net.Start("cs16_playerinfected")
        net.WriteEntity(self)
        net.WriteEntity(infecter)
        net.WriteBool(self.is_nemesis)
    net.Broadcast()

    if IsValid(infecter) and infecter:IsPlayer() then
        infecter:AddMoney(500, true)
        Notification("left", 2, GetLangRep("NOTICE_INFECT", {{"%s", self:Nick()}}), Color(255,0,0, 255))
    end
end

function meta_player:IsZombie()
    return (self:Team() == TEAM_T and game_state != GAMESTATE_PREPARING)
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

print("Gamemode loaded gamemodes/zombie_plague/sv_player_ext.lua")