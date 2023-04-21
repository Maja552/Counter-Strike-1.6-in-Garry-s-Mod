if CLIENT then
	SWEP.PrintName			= "Clarion 5.56"
	SWEP.Author				= "Schwarz Kruppzo"
end

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("cs/sprites/famas_selecticon")
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicons_new.Add("weapon_cs16_famas", "cs/sprites/famas_killicon", Color(255, 255, 255, 255))
end

SWEP.Slot				= 0
SWEP.SlotPos			= 1

SWEP.Base 				= "weapon_cs_base"
SWEP.Weight				= CS16_FAMAS_WEIGHT
SWEP.HoldType			= "ar2"

SWEP.Category			= "Counter-Strike"
SWEP.Spawnable			= true

--SWEP.PModel				= Model("models/weapons/cs16/p_famas.mdl")
SWEP.PModel				= Model("models/cs/p_famas.mdl")
SWEP.WModel				= Model("models/cs16/w_famas.mdl")
SWEP.VModel				= Model("models/weapons/cs16/c_famas.mdl")
--SWEP.VModel				= Model("models/cs/v_famas.mdl")

SWEP.ViewModel			= SWEP.VModel
SWEP.WorldModel			= SWEP.PModel

SWEP.Primary.Sound			= Sound("OldFAMAS.Shot1")
SWEP.Primary.EmptySound		= Sound("OldRifle.DryFire")
SWEP.Primary.ClipSize		= CS16_FAMAS_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_FAMAS_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_556NATO"
SWEP.Primary.Automatic		= true

SWEP.Secondary.Sound 		= Sound("OldFAMAS.Burst")

SWEP.AnimPrefix 			= "carbine"
SWEP.MaxSpeed 				= CS16_FAMAS_MAX_SPEED

if !gmod.GetGamemode().IsCStrike then
	SWEP.Slot			= 2
	SWEP.SlotPos		= 0
	SWEP.PModel			= Model("models/weapons/cs16/player/p_famas.mdl")
end

function SWEP:OnSetupDataTables()
	self:NetworkVar("Bool", 5, "BurstMode")
	self:NetworkVar("Float", 6, "FamasShoot")
	self:NetworkVar("Int", 1, "FamasShotsFired")
	self:NetworkVar("Float", 7, "BurstSpread")
end

function SWEP:OnDeploy()
	self:SendWeaponAnim(ACT_VM_DRAW)

	self:SetAccuracy(0.2)
	self:SetTimeWeaponIdle(CurTime() + 1.5)
end

function SWEP:PrimaryAttack()
	if self.Owner:WaterLevel() == 3 then
		self:EmitSound(self.Primary.EmptySound)
		self:SetNextPrimaryFire(CurTime() + 0.15)

		return
	end

	if !self.Owner:IsOnGround() then
		self:FamasFire(0.030 + 0.3 * self:GetAccuracy(), 0.0825)
	elseif self.Owner:GetVelocity():Length2D() > 140 then
		self:FamasFire(0.030 + 0.07 * self:GetAccuracy(), 0.0825)
	else
		self:FamasFire(0.02 * self:GetAccuracy(), 0.0825)
	end
end

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextSecondaryFire() then 
		return
	end

	if self:GetBurstMode() then
		self.Owner:OldPrintMessage("Switched to automatic")
		self:SetBurstMode(false)
	else
		self.Owner:OldPrintMessage("Switched to Burst-Fire mode")
		self:SetBurstMode(true)
	end

	self:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:NetworkedShootSound() -- a bit hacky
	self:EmitSound(self.Primary.Sound)
end

function SWEP:FireRemaining()
	if self:GetFamasShoot() >= CurTime() then
		return
	end

	self:TakePrimaryAmmo(1)

	if self:Clip1() <= 0 then
		self:SetClip1(0)
		self:SetFamasShotsFired(3)
		self:SetFamasShoot(0)
		return
	end

	self:FireAnimation()
	self.Owner:FireBullets3(self, self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), self:GetBurstSpread(), 8192, 2, "CS16_556NATO", 30, 0.96, self.Owner, true, self.Owner:EntIndex())
	
	if SERVER then
		self:NetworkedShootSound()
		self:CallOnClient("NetworkedShootSound")
	end

	self:CS16_MuzzleFlash(22, 30)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self:CreateShell(1, "1")

	self:SetFamasShotsFired(self:GetFamasShotsFired() + 1)

	if self:GetFamasShotsFired() == 3 then
		self:SetFamasShoot(0)
	else
		self:SetFamasShoot(CurTime() + 0.1)
	end
end

function SWEP:FireAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

function SWEP:RecalculateAccuracy()
	self:SetAccuracy(0.35 + ((self:GetShotsFired() * self:GetShotsFired() * self:GetShotsFired()) / 215) + 0.3)
end

function SWEP:FamasFire(flSpread, flCycleTime, burst)
	if self:Clip1() <= 0 then
		self:EmitSound(self.Primary.EmptySound)
		self:SetNextPrimaryFire(CurTime() + 0.2)

		return
	end

	if self:GetBurstMode() then
		self:SetFamasShotsFired(0)
		flCycleTime = 0.55
	else
		flSpread = flSpread + 0.01
	end

	self:SetDelayFire(true)
	self:SetShotsFired(self:GetShotsFired() + 1)
	self:RecalculateAccuracy()

	if self:GetAccuracy() > 1 then
		self:SetAccuracy(1)
	end

	self:FireAnimation()
	self:TakePrimaryAmmo(1)

	self:CS16_MuzzleFlash(22, 40)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self.Owner:FireBullets3(self, self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_FAMAS_DISTANCE, CS16_FAMAS_PENETRATION, "CS16_556NATO", CS16_FAMAS_DAMAGE, CS16_FAMAS_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex())

	local snd = self:GetBurstMode() and self.Secondary.Sound or self.Primary.Sound
	self:EmitSound(snd)

	self:CreateShell(1, "1")

	self:SetNextAttack(CurTime() + flCycleTime)
	self:SetTimeWeaponIdle(CurTime() + 1.1)

	if !self.Owner:IsOnGround() then
		self:KickBack(1.25, 0.45, 0.22, 0.18, 5.5, 4, 5)
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:KickBack(1, 0.45, 0.275, 0.05, 4, 2.5, 7)
	elseif self.Owner:Crouching() then
		self:KickBack(0.575, 0.325, 0.2, 0.011, 3.25, 2, 8)
	else
		self:KickBack(0.625, 0.375, 0.25, 0.0125, 3.5, 2.25, 8)
	end

	if self:GetBurstMode() then
		self:SetFamasShotsFired(self:GetFamasShotsFired() + 1)
		self:SetFamasShoot(CurTime() + 0.1)
		self:SetBurstSpread(flSpread)
	end
end

function SWEP:Reload()
	if self:GetInReload() then
		return 
	end

	if CLIENT and !IsFirstTimePredicted() then 
		return 
	end

	if self:CS16_DefaultReload(CS16_FAMAS_MAX_CLIP, ACT_VM_RELOAD, CS16_FAMAS_RELOAD_TIME) then
		self:SetAccuracy(0.2)
		self:SetShotsFired(0)
		self:SetDelayFire(false)
	end
end

function SWEP:WeaponIdle()
	if self:GetTimeWeaponIdle() > CurTime() then
		return
	end

	self:SetTimeWeaponIdle(CurTime() + 20)
	self:SendWeaponAnim(ACT_VM_IDLE)
end

function SWEP:OnThink()
	if self:GetFamasShoot() != 0 and IsFirstTimePredicted() then
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

		ShellVelocity, ShellOrigin = CS16_GetDefaultShellInfo(self.Owner, attach, velocity, ShellVelocity, ShellOrigin, angles, 17, -8, self.ViewModelFlip and 14 or -14, true)

		return ShellOrigin, ShellVelocity, angles.y
	end
end