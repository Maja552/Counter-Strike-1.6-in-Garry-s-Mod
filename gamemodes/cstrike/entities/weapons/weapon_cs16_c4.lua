if CLIENT then
	SWEP.PrintName			= "С4"
	SWEP.Author				= "Schwarz Kruppzo"
end

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("cs/sprites/c4_selecticon")
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicons_new.Add("weapon_cs16_c4", "cs/sprites/c4_killicon", Color(255, 255, 255, 255))
	killicons_new.Add("ent_cs16_planted_c4", "cs/sprites/c4_killicon", Color(255, 255, 255, 255))
end

SWEP.Slot				= 4
SWEP.SlotPos			= 1

SWEP.Base 				= "weapon_cs_base"
SWEP.Weight				= CS16_C4_WEIGHT
SWEP.HoldType			= "slam"

SWEP.Category			= "Counter-Strike"
SWEP.Spawnable			= false

--SWEP.PModel				= Model("models/weapons/cs16/p_c4.mdl")
SWEP.PModel				= Model("models/cs/p_c4.mdl")
SWEP.WModel				= Model("models/cs16/w_backpack.mdl")
--SWEP.VModel				= Model("models/weapons/cs16/c_c4.mdl")
SWEP.VModel				= Model("models/cs/v_c4.mdl")

SWEP.ViewModel			= SWEP.VModel
SWEP.WorldModel			= SWEP.PModel

SWEP.Primary.ClipSize		= CS16_C4_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_C4_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_C4"

SWEP.AnimPrefix 			= "c4"
SWEP.MaxSpeed 				= CS16_C4_MAX_SPEED
SWEP.Price 					= 0
SWEP.OnlyTeam 				= TEAM_T
SWEP.IsC4 					= true

function SWEP:OnSetupDataTables()
	self:NetworkVar("Bool", 5, "StartedArming")
	self:NetworkVar("Float", 6, "ArmedTime")
	self:NetworkVar("Bool", 6, "BombPlacedAnimation")
end

function SWEP:OnDeploy()
	self.WorldModel = self.PModel
	--self:SetModel(self.WModel)

	self:SendWeaponAnim(ACT_VM_DRAW)

	self:SetStartedArming(false)
	self:SetArmedTime(0)
	self.plant = false
	self:SetTimeWeaponIdle(CurTime() + 4)

	self.Owner:SetBodygroup(1, 1)
end

function SWEP:Reload()
	return
end

function SWEP:PrimaryAttack()
	return
end

function SWEP:PlantBomb(player, pos)
	local planted_c4 = ents.Create("ent_cs16_planted_c4")
	planted_c4:SetPos(pos)
	planted_c4:SetOwner(player)
	planted_c4:Spawn()
end

function SWEP:PrimaryFire()
	--if self:Clip1() <= 0 or self:GetNextPrimaryFire() < CurTime() or GetGlobalBool("m_bBombPlanted") then return end
	if self:Clip1() <= 0 or GetGlobalBool("m_bBombPlanted") then return end


	local onBombZone = self.Owner:IsInBombSite()
	local onGround   = bit.band(self.Owner:GetFlags(), FL_ONGROUND) > 0
	--print("onBombZone: ",onBombZone)

	if onBombZone and onGround then
		self.Owner.ArmingC4 = CurTime() + 0.1
	end

	if !self:GetStartedArming() then
		if !onBombZone then
			if SERVER then
				self.Owner:OldPrintMessage("C4 must be planted at a bomb site!")
			end

			self:SetNextPrimaryFire(CurTime() + 1)
			return
		end
		if !onGround then
			if SERVER then
				self.Owner:OldPrintMessage({"You must be standing on", "the ground to plant the C4!"})
			end

			self:SetNextPrimaryFire(CurTime() + 1)
			return
		end

		self:SetStartedArming(true)
		self:SetBombPlacedAnimation(false)
		self:SetArmedTime(CurTime() + 3)

		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self.Owner:SetAnimation(PLAYER_ATTACK1) 
		self.Owner:SetProgressBarTime(3)

		self:SetNextPrimaryFire(CurTime() + 0.3)
		self:SetTimeWeaponIdle(CurTime() + math.Rand(10, 15))
	else
		if !onGround or !onBombZone then
			if SERVER then
				if onBombZone then
					self.Owner:OldPrintMessage("The bomb must be on the ground")
				else
					self.Owner:OldPrintMessage("You must be standing on the ground to plant the C4!")
				end
			end

			self.Owner:SetProgressBarTime(0)
			self.Owner:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
			self:SendWeaponAnim(self:GetBombPlacedAnimation() and ACT_VM_DRAW or ACT_VM_IDLE)
			
			self:SetStartedArming(false)
			self:SetNextPrimaryFire(CurTime() + 1.5)
			return
		end

		if CurTime() >= self:GetArmedTime() then
			if self:GetStartedArming() then
				self.Owner:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
				self.plant = true 
				self:SetStartedArming(false)
				self:SetArmedTime(0)
				self.Owner:SetProgressBarTime(0)
				
				if SERVER then
					self:PlantBomb(self.Owner, self.Owner:GetPos())
					OldPrintMessage("The bomb has been planted")

					SetGlobalBool("m_bBombPlanted", true)
					
					--play the sound
					net.Start("cs16_planted_c4")
					net.Broadcast()
				end

				self:EmitSound("OldC4.Plant")
				
				self:TakePrimaryAmmo(1)
				if SERVER then 	
					if self.Owner.CS16_SelectBestWeapon then
						self.Owner:CS16_SelectBestWeapon(self)
					else
						self.Owner:ConCommand("lastinv")
					end

					SafeRemoveEntity(self)
				end
			end
		else
			if CurTime() >= self:GetArmedTime() - 0.75 and !self:GetBombPlacedAnimation() then
				self.Owner:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
				self:SetBombPlacedAnimation(true)

				self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
			end
		end
	end

	--self:SetNextPrimaryFire(CurTime() + 0.3)
	self:SetTimeWeaponIdle(CurTime() + math.Rand(10, 15))
end

function SWEP:OnThink()
	self:WeaponIdle()
end

function SWEP:WeaponIdle()
	if self.Owner:KeyDown(IN_ATTACK) and !GetGlobalBool("m_bBombPlanted") then
		self:PrimaryFire()
	else
		--if true then return end
		if self:GetStartedArming() then
			self:SetStartedArming(false)
			self.Owner:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
			self:SetNextPrimaryFire(CurTime() + 1)
			self.Owner:SetProgressBarTime(0)

			self:SendWeaponAnim(self:GetBombPlacedAnimation() and ACT_VM_DRAW or ACT_VM_IDLE)
		end

		
		if self:GetTimeWeaponIdle() <= CurTime() then
			if self:Clip1() <= 0 then
				if SERVER then 
					self.Owner:ConCommand("lastinv")

					SafeRemoveEntity(self)
				end

				return
			end

			self:SendWeaponAnim(ACT_VM_DRAW)
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
		
		
	end
end

function SWEP:OnHolster()
	self.plant = false
	self:SetStartedArming(false)
	self:SetArmedTime(0)
end

function SWEP:IsPistol()
	return true
end

function SWEP:OnPickup(ply)
	ply:OldPrintMessage("You picked up the bomb!")
	ply:SetBodygroup(1, 1)
end

function SWEP:OnCS16DropSH(ply)
	self.WorldModel = self.WModel
	self:SetModel(self.WModel)
end

function SWEP:OnCS16Drop(ply)
	if IsValid(ply) and ply:Alive() and !ply:IsSpectator() then
		ply:SetBodygroup(1, 0)
	end
	self:OnCS16DropSH(ply)
	net.Start("cs16_droppedweapon")
		net.WriteEntity(self)
		net.WriteEntity(ply)
	net.Broadcast()

	self:MakeSolid()

	OldPrintMessage(ply:Nick().." dropped the bomb")
end
