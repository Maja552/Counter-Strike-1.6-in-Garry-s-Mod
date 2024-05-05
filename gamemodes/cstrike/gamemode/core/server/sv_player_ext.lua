local meta_player = FindMetaTable("Player")

hook.Add("Tick", "FreezeTick", function()
	for k,v in pairs(player.GetAll()) do
		if v.frozen and v.frozen_for < CurTime() then
			v.frozen = false
			hook.Call("CS16_OnPlayerFreezeBreak", GAMEMODE, v)
		end
	end
end)

function meta_player:Freeze(duration)
	self.frozen_pos = self:GetPos()
	self.frozen_for = CurTime() + duration
	self.frozen = true
	net.Start("cs16_freezeplayer")
		net.WriteEntity(self)
		net.WriteInt(duration, 16)
	net.Broadcast()
	hook.Call("CS16_OnPlayerFrozen", GAMEMODE, self)
end

function meta_player:CloakTil(duration)
	self.cloaked_til = CurTime() + duration
	net.Start("cs16_cloakplayer")
		net.WriteEntity(self)
		net.WriteInt(duration, 16)
	net.Broadcast()
end

function meta_player:SetHuman()
	return SUBGAMEMODE:PlayerSetHuman(self)
end

function meta_player:AfterSetHuman()
	local ply = self
	hook.Call("PlayerSetModel", GAMEMODE, ply)
	ply:SetupHands()
end

function meta_player:Radio(sound, name)
	if self.nextRadioSound < CurTime() then
		self:EmitSound(sound)
		self.lastRadioSound = {sound, name}
	end
end

function meta_player:DropAllWeapons()
	self:SetNWBool("HasNVG", false)
	self:SetNWBool("HasSilentBoots", false)
	self:SendLua("LocalPlayer().CS16_NVG_ENABLED = false")

	for k,v in pairs(self:GetWeapons()) do
        local candrop = true
        if isfunction(v.CanDrop) then
            candrop = v:CanDrop()
        end

		if candrop then
			self:DropWep(v, 25)
		end
	end
end

function meta_player:CS16_SelectBestWeapon()
	local all_weps = self:GetWeapons()
	for k,v in pairs(all_weps) do
		if v.Slot == 0 then
			self:SelectWeapon(v:GetClass())
			return
		end
	end

	for k,v in pairs(all_weps) do
		if v.Slot == 1 then
			self:SelectWeapon(v:GetClass())
			return
		end
	end

	for k,v in pairs(all_weps) do
		if v.Slot == 2 then
			self:SelectWeapon(v:GetClass())
			return
		end
	end
end

function meta_player:Blind()
end

function meta_player:BuyCS16Grenade(class, ammo_type, cost)
	local ply = self
	if ply:HasWeapon(class) then
		local wep = ply:GetWeapon(class)
		if ply:GetAmmoCount(wep:GetPrimaryAmmoType()) == 1 or wep:Clip1() < 0 then
			ply:AddMoney(cost, true)
			ply:GiveAmmo(1, ammo_type, false)
			return true
		end
	else
		ply:GiveAmmo(1, ammo_type, true)
		local bang = ply:Give(class)
		if IsValid(bang) then
			ply:AddMoney(cost, true)
		else
			ply:GiveAmmo(-1, ammo_type, true)
		end
		return true
	end
	return false
end

local show_ammo_popup = false
function meta_player:BuyCS16Ammo(slot)
	local ply = self
	for k,v in pairs(ply:GetWeapons()) do
		if v:GetSlot() == slot then
			local ammo_info = CS16_AMMO_PRICES[v.Primary.Ammo]
			if ammo_info then
				local clip = v.Primary.ClipSize
				local price = ammo_info[2]
				local ammo_type = v:GetPrimaryAmmoType()
				local ammo_data = game.GetAmmoData(ammo_type)
				if clip and ammo_data and ammo_data.maxcarry then
					local need = ammo_data.maxcarry - ply:GetAmmoCount(ammo_type)
					if need > 0 then
						if clip > need then
							local price2 = math.Clamp(math.Round(price * (need / clip)), 1, price)
							if self.cs16_money < price2 then return end
							ply:GiveAmmo(need, ammo_data.name, show_ammo_popup)
							--ply:EmitSound("items/ammo_pickup.wav")
							timer.Simple(math.Rand(0.01,0.05), function() ply:EmitSound("items/ammo_pickup.wav") end)
							ply:AddMoney(-price2, true)
						else
							for i=1, 8 do
								if need >= clip then
									if self.cs16_money < price then return false end
									ply:GiveAmmo(clip, ammo_data.name, show_ammo_popup)
									--ply:EmitSound("items/ammo_pickup.wav")
									timer.Simple(math.Rand(0.01,0.05), function() ply:EmitSound("items/ammo_pickup.wav") end)
									ply:AddMoney(-price, true)
									need = need - clip
									if need == 0 then break end
								else
									local price2 = math.Clamp(math.Round(price * (need / clip)), 1, price)
									if self.cs16_money < price2 then return false end
									ply:GiveAmmo(need, ammo_data.name, show_ammo_popup)
									timer.Simple(math.Rand(0.01,0.05), function() ply:EmitSound("items/ammo_pickup.wav") end)
									--ply:EmitSound("items/ammo_pickup.wav")
									ply:AddMoney(-price2, true)
									break
								end
							end
						end
					end
					ply:UpdateMoney()
				end
			end
			return true
		end
	end
end

function meta_player:DropWep(wep, force)
	force = force or 500
	self:DropWeapon(wep, nil, self:EyeAngles():Forward() * force)
	if wep.OnCS16Drop then
		wep:OnCS16Drop(self)
	end
end

function meta_player:CanPlantBomb()
    return (self:Team() == TEAM_T and (game_state == GAMESTATE_ROUND or game_state == GAMESTATE_POSTROUND))
end

function meta_player:SetCS16Team(team_id, update)
	self.cs16_team = team_id
	if update then
		self:UpdateCS16Team()
	end
end

util.AddNetworkString("cs16_updateteam")
function meta_player:UpdateCS16Team()
    net.Start("cs16_updateteam")
        net.WriteEntity(self)
        net.WriteInt(self.cs16_team, 8)
    net.Broadcast()
end

function meta_player:SetSpectator()
	self:StripWeapons()
	self:SetNoDraw(true)
	self:SetNoTarget(true)
	self:SetTeam(TEAM_SPECTATOR)
	self:Spectate(OBS_MODE_ROAMING)
	--self:SetMoveType(MOVETYPE_OBSERVER)

	if !self.spect_notif_fired and game_state != GAMESTATE_NOTSTARTED then
		self:GreenNotification({"Press RELOAD to change the observer mode", "Attacks change the observed target"})
		self.spect_notif_fired = true
	end
end

print("Gamemode loaded sv_player_ext.lua")