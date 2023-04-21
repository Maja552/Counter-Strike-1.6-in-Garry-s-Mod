if CLIENT then
	SWEP.PrintName			= "9x19mm Sidearm"
	SWEP.Author				= "Schwarz Kruppzo"
end

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("cs/sprites/glock_selecticon")
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicons_new.Add("weapon_cs16_glock18", "cs/sprites/glock_killicon", Color(255, 255, 255, 255))
end

SWEP.Slot				= 1
SWEP.SlotPos			= 1

SWEP.Base 				= "weapon_cs_base"
SWEP.Weight				= CS16_GLOCK18_WEIGHT
SWEP.HoldType			= "pistol"

SWEP.Category			= "Counter-Strike"
SWEP.Spawnable			= true


--SWEP.PModel				= Model("models/weapons/cs16/p_glock18.mdl")
SWEP.PModel				= Model("models/cs/p_glock18.mdl")
SWEP.WModel				= Model("models/cs16/w_glock18.mdl")
SWEP.VModel				= Model("models/weapons/cs16/c_glock18.mdl")
--SWEP.VModel				= Model("models/cs/v_glock18.mdl")

SWEP.PModelShield		= Model("models/weapons/cs16/shield/p_shield_glock18.mdl")
SWEP.VModelShield		= Model("models/weapons/cs16/shield/v_shield_glock18.mdl")

SWEP.ViewModel			= SWEP.VModel
SWEP.WorldModel			= SWEP.PModel

SWEP.Primary.Sound			= Sound("OldGlock.Shot1")
SWEP.Primary.EmptySound		= Sound("OldPistol.DryFire")
SWEP.Primary.ClipSize		= CS16_GLOCK18_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_GLOCK18_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_9MM"

SWEP.AnimPrefix 			= "pistol"
SWEP.MaxSpeed 				= CS16_GLOCK18_MAX_SPEED
SWEP.Price 					= 400

if !gmod.GetGamemode().IsCStrike then
	SWEP.PModel			= Model("models/weapons/cs16/player/p_glock18.mdl")
end

function SWEP:OnSetupDataTables()
	self:NetworkVar("Bool", 5, "BurstMode")
	self:NetworkVar("Float", 6, "Glock18Shoot")
	self:NetworkVar("Int", 1, "Glock18ShotsFired")
end

function SWEP:OnDeploy()
	if self.Owner:HasShield() then
		self:SetBurstMode(false)
		self.ViewModel = self.VModelShield
		self.Owner:GetViewModel():SetWeaponModel(self.ViewModel, self)
	else
		self.ViewModel = self.VModel
		self.Owner:GetViewModel():SetWeaponModel(self.ViewModel, self)
	end

	local vm = self.Owner:GetViewModel()

	vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_DRAW))

	self:SetAccuracy(0.9)
	self:SetTimeWeaponIdle(CurTime() + 4)
end

function SWEP:PrimaryAttack()
	if self.Owner:IsShieldDrawn() then return end

	if self:GetBurstMode() then
		if !self.Owner:IsOnGround() then
			self:GLOCK18Fire(1.2 * (1 - self:GetAccuracy()), 0.5)
		elseif self.Owner:GetVelocity():Length2D() > 0 then
			self:GLOCK18Fire(0.185 * (1 - self:GetAccuracy()), 0.5)
		elseif self.Owner:Crouching() then
			self:GLOCK18Fire(0.095 * (1 - self:GetAccuracy()), 0.5)
		else
			self:GLOCK18Fire(0.3 * (1 - self:GetAccuracy()), 0.5)
		end
	else
		if !self.Owner:IsOnGround() then
			self:GLOCK18Fire(1.0 * (1 - self:GetAccuracy()), 0.2)
		elseif self.Owner:GetVelocity():Length2D() > 0 then
			self:GLOCK18Fire(0.165 * (1 - self:GetAccuracy()), 0.2)
		elseif self.Owner:Crouching() then
			self:GLOCK18Fire(0.075 * (1 - self:GetAccuracy()), 0.2)
		else
			self:GLOCK18Fire(0.1 * (1 - self:GetAccuracy()), 0.2)
		end
	end
end

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextSecondaryFire() then 
		return
	end

	if self:ShieldSecondaryAttack() then
		return
	end

	if self:GetBurstMode() then
		self.Owner:OldPrintMessage("Switched to semi-automatic")
		self:SetBurstMode(false)
	else
		self.Owner:OldPrintMessage("Switched to Burst-Fire mode")
		self:SetBurstMode(true)
	end

	self:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:FireAnimation(empty)
	local vm = self.Owner:GetViewModel()
	local anim = ACT_VM_DRYFIRE

	if !empty then
		if self:GetBurstMode() then
			anim = self:Clip1() == 1 and ACT_VM_DRYFIRE or ACT_VM_SECONDARYATTACK
		else
			anim = self:Clip1() == 1 and ACT_VM_DRYFIRE or ACT_VM_PRIMARYATTACK
		end
	end

	vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(anim))
end

function SWEP:GLOCK18Fire(flSpread, flCycleTime)
	if self:Clip1() <= 0 then
		self:EmitSound(self.Primary.EmptySound)
		self:SetNextPrimaryFire(CurTime() + 0.2)

		return
	end

	if self:GetBurstMode() then
		self:SetGlock18ShotsFired(0)
	else
		self:SetShotsFired(self:GetShotsFired() + 1)

		if self:GetShotsFired() > 1 then
			return
		end

		--flCycleTime = flCycleTime - 0.05
		flCycleTime = flCycleTime - 0.08
	end

	if self:GetLastFire() != 0 then
		self:SetAccuracy(math.Clamp(self:GetAccuracy() - (0.325 - (CurTime() - self:GetLastFire())) * 0.275, 0.6, 0.9))
	end

	local empty = false
	if self:GetBurstMode() then 
		empty = (self:Clip1() - 3) <= 0 and true or false
	end

	self:SetLastFire(CurTime())
	self:FireAnimation(empty)
	self:TakePrimaryAmmo(1)

	self:CS16_MuzzleFlash(21, 10)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self.Owner:FireBullets3(self, self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_GLOCK18_DISTANCE, CS16_GLOCK18_PENETRATION, "CS16_9MM", CS16_GLOCK18_DAMAGE, CS16_GLOCK18_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex())

	self:EmitSound(self.Primary.Sound)

	self.Owner:CS16_SetViewPunch(self.Owner:CS16_GetViewPunch() + Angle(-0.5, 0, 0), true)

	local eject = self.Owner:HasShield() and "0" or "1"
	self:CreateShell(0, eject)

	self:SetTimeWeaponIdle(CurTime() + 2)
	self:SetNextPrimaryFire(CurTime() + flCycleTime)

	if self:GetBurstMode() then
		self:SetGlock18ShotsFired(self:GetGlock18ShotsFired() + 1)
		self:SetGlock18Shoot(CurTime() + 0.1)
	end
end

function SWEP:NetworkedShootSound() -- a bit hacky
	self:EmitSound(self.Primary.Sound)
end

function SWEP:FireRemaining()
	self:TakePrimaryAmmo(1)

	if self:Clip1() <= 0 then
		self:SetClip1(0)
		self:SetGlock18ShotsFired(3)
		self:SetGlock18Shoot(0)
		return
	end

	self.Owner:FireBullets3(self, self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), 0.05, 8192, 1, "CS16_9MM", 18, 0.9, self.Owner, true, self.Owner:EntIndex())

	if SERVER then
		self:NetworkedShootSound()
		self:CallOnClient("NetworkedShootSound")
	end

	self:CS16_MuzzleFlash(21, 10)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self:CreateShell(0, "1")

	self:SetGlock18ShotsFired(self:GetGlock18ShotsFired() + 1)

	if self:GetGlock18ShotsFired() == 3 then
		self:SetGlock18Shoot(0)
	else
		self:SetGlock18Shoot(CurTime() + 0.1)
	end
end

function SWEP:Reload()
	if self:GetInReload() then
		return 
	end

	if CLIENT and !IsFirstTimePredicted() then 
		return 
	end

	if self:CS16_DefaultReload(CS16_GLOCK18_MAX_CLIP, ACT_VM_RELOAD, CS16_GLOCK18_RELOAD_TIME, true) then
		self:SetAccuracy(0.9)
	end
end

function SWEP:WeaponIdle()
	if self:GetTimeWeaponIdle() > CurTime() then
		return
	end

	local vm = self.Owner:GetViewModel()

	if self.Owner.HasShield and self.Owner:HasShield() then
		self:SetTimeWeaponIdle(CurTime() + 20)

		if self.Owner:IsShieldDrawn() then
			vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_SHIELD_UP_IDLE))
		end
	elseif self:Clip1() != 0 then 
		local random = math.Rand(0, 1)

		if random <= 0.3 then 
			self:SetTimeWeaponIdle(CurTime() + 3.0625)

			vm:SendViewModelMatchingSequence(vm:LookupSequence("idle3"))
		elseif random <= 0.6 then 
			self:SetTimeWeaponIdle(CurTime() + 3.75)

			vm:SendViewModelMatchingSequence(vm:LookupSequence("idle1"))
		else
			self:SetTimeWeaponIdle(CurTime() + 2.5)

			vm:SendViewModelMatchingSequence(vm:LookupSequence("idle2"))
		end
	end
end

function SWEP:IsPistol()
	return true
end

function SWEP:OnThink()
	if self:GetGlock18Shoot() != 0 and IsFirstTimePredicted() then
		self:FireRemaining()
	end
end

if CLIENT then
	function SWEP:GetShellDir(attach)
		local ShellVelocity, ShellOrigin = Vector(), Vector()
		local velocity = self.Owner:GetVelocity()
		local punchangle = self.Owner:CS16_GetViewPunch()
		local angles = self.Owner:EyeAngles()
		angles.x = punchangle.x + angles.x
		angles.y = punchangle.y + angles.y

		ShellVelocity, ShellOrigin = CS16_GetDefaultShellInfo(self.Owner, attach, velocity, ShellVelocity, ShellOrigin, angles, 36, -14, self.ViewModelFlip and 14 or -14, false)

		return ShellOrigin, ShellVelocity, angles.y
	end
end