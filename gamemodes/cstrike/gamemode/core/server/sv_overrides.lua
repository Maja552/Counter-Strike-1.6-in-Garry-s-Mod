
-- replaced
function GM:PlayerSpray(sprayer)
    return true
end

function GM:PlayerCanHearPlayersVoice(listener, talker)
    return SUBGAMEMODE:PlayerCanHearPlayersVoice(listener, talker)
end

function GM:PlayerCanSeePlayersChat(text, teamOnly, listener, talker)
    return SUBGAMEMODE:PlayerCanSeePlayersChat(text, teamOnly, listener, talker)
end

function GM:GetFallDamage(ply, speed)
    return speed / 14
    --return math.max(0, math.ceil(0.2418 * speed - 141.75))
end

function GM:PlayerDeathSound(ply)
    return SUBGAMEMODE:PlayerDeathSound(ply)
end

function GM:ScalePlayerDamage(ply, hitgroup, dmginfo)
    SUBGAMEMODE:PlayerDamageSounds(ply, hitgroup, dmginfo)
    return SUBGAMEMODE:ScalePlayerDamage(ply, hitgroup, dmginfo)
end

print("Gamemode loaded sv_overrides.lua")