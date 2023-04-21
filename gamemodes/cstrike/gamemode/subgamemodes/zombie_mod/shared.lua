
-- The whole config of the subgamemode
SUBGAMEMODE.CONFIG = table.Copy(GM.DEFAULT_CONFIG)
SUBGAMEMODE.CONFIG.PREPARING_FREEZE = false
SUBGAMEMODE.CONFIG.UNIFIED_SPAWNPOINTS = true
SUBGAMEMODE.CONFIG.SPAWNPOINTS = "info_player_deathmatch"
SUBGAMEMODE.CONFIG.INFINITE_AMMO = true
SUBGAMEMODE.CONFIG.FREEZE_GRENADE_DURATION = 8
SUBGAMEMODE.CONFIG.STARTING_MONEY = 6000
SUBGAMEMODE.CONFIG.MAX_MONEY = 16000
SUBGAMEMODE.CONFIG.FLASHLIGHT_ENABLED = false
SUBGAMEMODE.CONFIG.CAN_BUY_ANYWHERE = true
SUBGAMEMODE.CONFIG.ZOMBIE_MADNESS_DURATION = 6
SUBGAMEMODE.CONFIG.MAX_BARRICADES = 2

SUBGAMEMODE.CONFIG.GUN_ON_START = {
    "weapon_cs16_mp5navy",
    "weapon_cs16_mac10",
    "weapon_cs16_ump45",
    "weapon_cs16_tmp",
    "weapon_cs16_m3"
}

SUBGAMEMODE.CONFIG.CLASSES = {
    zm_balanced = {
        on_zombie_set = function(ply)
        end,
    },
    zm_speed = {
        on_zombie_set = function(ply)
            ply:SetHealth(ply:Health() * 0.9)
            ply:SetMaxHealth(ply:Health())

            ply.speed_walking = SUBGAMEMODE.CONFIG.DEFAULT_WALK_SPEED * 1.2
            ply.jump_power = SUBGAMEMODE.CONFIG.DEFAULT_JUMP_POWER
            ply.speed_limit_enabled = false
            ply:SetCrouchedWalkSpeed(0.4)

            ply:SetModel("models/player/zombie_fast.mdl")
        end,
    },
    zm_jump = {
        on_zombie_set = function(ply)
            ply:SetHealth(ply:Health() * 0.9)
            ply:SetMaxHealth(ply:Health())

            ply.speed_walking = SUBGAMEMODE.CONFIG.DEFAULT_WALK_SPEED
            ply.jump_power = SUBGAMEMODE.CONFIG.DEFAULT_JUMP_POWER * 1.5
            ply.speed_limit_enabled = false

            --ply:SetModel("models/player/zombie_fast.mdl")
        end,
    },
    zm_hp = {
        on_zombie_set = function(ply)
            ply:SetHealth(ply:Health() * 1.2)
            ply:SetMaxHealth(ply:Health())

            ply.speed_walking = SUBGAMEMODE.CONFIG.DEFAULT_WALK_SPEED * 0.85
            ply.jump_power = SUBGAMEMODE.CONFIG.DEFAULT_JUMP_POWER * 0.9
            ply.speed_limit_enabled = false
            ply:SetCrouchedWalkSpeed(0.33)
        end,
    },
    zm_radioactive = {
        on_zombie_set = function(ply)
            ply:SetHealth(ply:Health() * 0.85)
            ply:SetMaxHealth(ply:Health())

            ply.next_radioactive_attack = CurTime() + 1
            ply.is_radioactive = true
        end,
    }
}

SUBGAMEMODE.CONFIG.LANG = {
    WIN_ZOMBIE = "Zombies have taken over the world!",
    WIN_HUMAN = "Humans defeated the plague!",
    WIN_HUMANS_TIME = "Humans have survived!",
    WIN_NO_ONE = "No one won...",
    NOTICE_VIRUS_FREE = "The T-Virus has been set loose...",
    NOTICE_FIRST = "%s is the first zombie !!",
    NOTICE_INFECT = "%s's brains have been eaten...",
    NOTICE_ANTIDOTE = "%s has used an antidote...",
    NOTICE_NEMESIS = "%s is a Nemesis !!!",
    NOTICE_SURVIVOR = "%s is a Survivor !!!",
    NOTICE_SWARM = "Swarm Mode !!!",
    NOTICE_PLAGUE = "Plague Mode !!!",
    NOTICE_MULTI = "Multiple Infection !!!",
    NOTICE_LASTHUMAN = "%s is the last human alive",
    NOTICE_ZOMBIESPAWN_LIVES = "Spawning in %t seconds, %n zombie %s left...",
    NOTICE_SPAWN = "Spawning in 5 seconds..."
}

local snd_path = "cstrike/zombie_mod/"

SUBGAMEMODE.CONFIG.SOUNDS = {
    BARRICADE_BREAK_SOUND = {"weapons/exp1.wav", "weapons/exp2.wav", "weapons/exp3.wav"},
    LAST_HUMAN_LEFT = snd_path.."nil_last.wav",
    WIN_ZOMBIE = {
        snd_path.."the_horror1.wav",
        snd_path.."the_horror3.wav",
        snd_path.."the_horror4.wav"
    },
    WIN_HUMAN = {
        snd_path.."win_humans1.wav",
        snd_path.."win_humans2.wav"
    },
    WIN_NO_ONE = {
        snd_path.."win_noone.wav"
    },
    ANTIDOTE = snd_path.."smallmedkit1.wav",
    COUNTDOWN = snd_path.."countdown_female.wav",
    ROUND_NEMESIS = {snd_path.."nemesis2.wav"},
    ROUND_SURVIVOR = {snd_path.."survivor1.wav", snd_path.."survivor2.wav"},
    ROUND_SWARM = {snd_path.."the_horror2.wav"},
    ROUND_MULTI = {snd_path.."the_horror2.wav"},
    ROUND_PLAGUE = {snd_path.."survivor1.wav"},
    GRENADE_INFECT_EXPLODE = {snd_path.."grenade_infect.wav"},
    GRENADE_INFECT_PLAYER = {snd_path.."scream20.wav", snd_path.."scream22.wav", snd_path.."scream05.wav"},
    GRENADE_FIRE_EXPLODE = {snd_path.."grenade_explode.wav"},
    GRENADE_FIRE_PLAYER = {snd_path.."zombie_burn3.wav", snd_path.."zombie_burn4.wav", snd_path.."zombie_burn5.wav", snd_path.."zombie_burn6.wav", snd_path.."zombie_burn7.wav"},
    GRENADE_FROST_EXPLODE = {snd_path.."frostnova.wav"},
    GRENADE_FROST_PLAYER = {snd_path.."impalehit.wav"},
    GRENADE_FROST_BREAK = {snd_path.."impalelaunch1.wav"},
    GRENADE_FLARE = {"cstrike/items/nvg_on.wav"},
    THUNDER = {snd_path.."thunder1.wav", snd_path.."thunder2.wav"},
    ZOMBIE_PAIN = {snd_path.."zombie_pain1.wav", snd_path.."zombie_pain2.wav", snd_path.."zombie_pain3.wav", snd_path.."zombie_pain4.wav", snd_path.."zombie_pain5.wav"},
    HUMAN_PAIN = {"cstrike/player/pl_pain2.wav", "cstrike/player/pl_pain4.wav", "cstrike/player/pl_pain5.wav", "cstrike/player/pl_pain6.wav", "cstrike/player/pl_pain7.wav"},
    NEMESIS_PAIN = {snd_path.."nemesis_pain1.wav", snd_path.."nemesis_pain2.wav", snd_path.."nemesis_pain3.wav"},
    ZOMBIE_DIE = {snd_path.."zombie_die1.wav", snd_path.."zombie_die2.wav", snd_path.."zombie_die3.wav", snd_path.."zombie_die4.wav", snd_path.."zombie_die5.wav"},
    ZOMBIE_FALL = {snd_path.."zombie_fall1.wav"},
    --ZOMBIE_MISS_SLASH = {"weapons/knife_slash1.wav", "weapons/knife_slash2.wav"},
    --ZOMBIE_MISS_WALL = {"weapons/knife_hitwall1.wav"},
    --ZOMBIE_HIT_NORMAL = {"weapons/knife_hit1.wav", "weapons/knife_hit2.wav", "weapons/knife_hit3.wav", "weapons/knife_hit4.wav"},
    --ZOMBIE_HIT_STAB = {"weapons/knife_stab.wav"},
    --ZOMBIE_IDLE_LAST = {snd_path.."nil_thelast.wav"},
    ZOMBIE_MADNESS = {snd_path.."zombie_madness1.wav"},
    ZOMBIE_IDLE = {
        {snd = snd_path.."zombie_brains1.wav", len = 2},
        {snd = snd_path.."zombie_brains2.wav", len = 3},
        {snd = snd_path.."nil_alone.wav", len = 8},
        {snd = snd_path.."nil_now_die.wav", len = 8},
        {snd = snd_path.."nil_slaves.wav", len = 8},
        {snd = snd_path.."nil_win.wav", len = 5}
    },
    ZOMBIE_ON_INFECT = {
        snd_path.."c1a0_sci_catscream.wav",
        snd_path.."scream01.wav",
        snd_path.."zombie_infec1.wav",
        snd_path.."zombie_infec2.wav",
        snd_path.."zombie_infec3.wav"
    }
}

function GetCS16Sound(name)
    local input = SUBGAMEMODE.CONFIG.SOUNDS[name]
    if isstring(input) then return input end
    if istable(input) then return input[math.random(#input)] end
end

SUBGAMEMODE.CONFIG.WinConditions = {
    [TEAM_T] = {
        on_win_cl = function()
            print("zombies have won the round!")
            surface.PlaySound(GetCS16Sound("WIN_ZOMBIE"))
        end
    },
    [TEAM_CT] = {
        on_win_cl = function()
            print("humans have won the round!")
            surface.PlaySound(GetCS16Sound("WIN_HUMAN"))
        end
    },
    [WIN_TIME] = {
        on_win_cl = function()
            --print("no one won")
            print("humans have survived the round!")
            surface.PlaySound(GetCS16Sound("WIN_NO_ONE"))
        end
    },
    [WIN_DRAW] = {
        on_win_cl = function()
            print("round draw")
            surface.PlaySound('cstrike/radio/rounddraw.wav')
        end
    },
}

SUBGAMEMODE.CONFIG.DEFAULT_MOTD = [[
Zombie Plague is a Counter-Strike server side modification, developed as an AMX Mod X plugin, which completely revamps the gameplay, turning the game into an intense "Humans vs Zombies" survival experience.
]]

print("Gamemode loaded gamemodes/zombie_mod/shared.lua")