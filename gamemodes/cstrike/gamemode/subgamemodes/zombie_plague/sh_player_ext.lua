local meta_player = FindMetaTable("Player")

function meta_player:HasZombieClaws()
    for k,v in pairs(self:GetWeapons()) do
        if v.IsZombieClaws == true then
            return true
        end
    end
    return false
end

print("Gamemode loaded gamemodes/zombie_plague/sh_player_ext.lua")