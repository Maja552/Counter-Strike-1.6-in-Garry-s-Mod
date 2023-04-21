local meta_player = FindMetaTable("Player")

hook.Add("ShouldCollide", "zm_barricade_custom_collisions", function(ent1, ent2)
    local ent1_is_pl = ent1:IsPlayer()
    local ent2_is_pl = ent2:IsPlayer()
	if (ent1:GetClass() == "zm_barricade" and ent2_is_pl and !ent2:IsZombie())
    or (ent2:GetClass() == "zm_barricade" and ent1_is_pl and !ent1:IsZombie())
    or game_state == GAMESTATE_NOTSTARTED and (ent1_is_pl or ent2_is_pl)
    then
		return false
	end
end)

function meta_player:IsZombie()
    return (self:Team() == TEAM_T and game_state != GAMESTATE_PREPARING)
end

function meta_player:HasZombieClaws()
    for k,v in pairs(self:GetWeapons()) do
        if v.IsZombieClaws == true then
            return true
        end
    end
    return false
end

function meta_player:IsSurvivor()
    return (self:HasWeapon("weapon_cs16_zm_m249") and self:GetMaxHealth() == 1000)
end

function meta_player:IsNemesis()
    return self.is_nemesis
end

print("Gamemode loaded gamemodes/zombie_mod/sh_player_ext.lua")