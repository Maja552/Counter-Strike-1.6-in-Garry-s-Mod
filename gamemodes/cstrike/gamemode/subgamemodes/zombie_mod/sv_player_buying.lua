
function SUBGAMEMODE:PlayerCanBuy(ply)
    if game_state == GAMESTATE_POSTROUND or ply:IsSurvivor() or ply.frozen_for > CurTime() then return false end
    if ply:Team() == TEAM_T then
        return ZM_RoundType().zombie_buymenu_enabled
    end
    return true
end

GM:SubGamemodeHook_Add("CS16_OnPlayerBought", "CS16_ZM_PlayerBought", function(ply, name, cost, should_count)
    if cost < 0 then
        cost = -cost
    end
    if should_count != false then
        ply.zm_spent = ply.zm_spent + cost
    end
    print(ply:Nick().." has bought "..name.." for "..cost.."$")
end)

print("Gamemode loaded gamemodes/zombie_mod/sv_player_buying.lua")