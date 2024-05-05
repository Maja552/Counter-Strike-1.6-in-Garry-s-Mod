
CS16_DefaultGamemode = "paintball"

CS16_Gamemodes = {
    -- This subgamemode contains the default config and functions for other subgamemodes
    _defaults = {
        name = "defaults",
        hide = true,
    },
    cstrike = {
        name = "Counter-Strike",
    },
    zombie_mod = {
        name = "Zombie Mod", -- bugged beyond human comprehension
    },
    zombie_plague = {
        name = "Zombie Plague", -- rewrite of zombie mod
    },
    hide_and_seek = {
        name = "Hide and Seek",
    }
}

/*
Vanilla
    Hostage rescue + Bomb defusal, Retakes
        Casual,         ^ Competetive ^

Action
    Deathmatch, Gun game, Paintball, 3 teams, Cod mod
    
Biohazard
    Zombie plague, Zombie escape, Zombie hell

Fun
    Hide and seek, Chase, Jailbreak, Flowers, Monster, Hidden, Deathrun, Bhop

Focused
    Assasination, Escape

Campaign
    Tour of duty, Deleted scenes
*/

CS16_Current_Gamemode = nil

local function CheckSubGamemode(subgm)
    if !file.Exists("cs16", "DATA") then
        file.CreateDir("cs16")
    end
    if !file.Exists("cs16/current_subgamemode.txt", "DATA") then
        file.Write("cs16/current_subgamemode.txt", subgm)
    end
end

function GM:SubGamemodeHook_Add(event_name, identifier, func)
    hook.Add(event_name, identifier, func)
    SUBGAMEMODE.HOOKS[event_name] = identifier
end

function GM:SubGamemodeHook_Remove(event_name, identifier, func)
    hook.Remove(event_name, identifier)
    SUBGAMEMODE.HOOKS[event_name] = nil
end

-- Loads up a subgamemode
function GM:LoadSubGamemode(subgm, change)
    if SUBGAMEMODE and SUBGAMEMODE.HOOKS then
        for k,v in pairs(SUBGAMEMODE.HOOKS) do
            self:SubGamemodeHook_Remove(k,v)
        end
    end

    CS16_Current_Gamemode = subgm
    SUBGAMEMODE = {}
    SUBGAMEMODE.class = subgm
    SUBGAMEMODE.CONFIG = {}
    SUBGAMEMODE.HOOKS = {}

    local path = "subgamemodes/"..subgm.."/"
    if SERVER then
        include(path.."init.lua")
        AddCSLuaFile(path.."cl_init.lua")
    else
        include(path.."cl_init.lua")
    end

    if SUBGAMEMODE.OnInitialize then
        SUBGAMEMODE.OnInitialize()
    end

    -- Changing to a different subgamemode
    if change then
    end
end

GM:LoadSubGamemode("_defaults", false)
GM:LoadSubGamemode(CS16_DefaultGamemode, false)

print("Gamemode loaded sh_gamemodes.lua")