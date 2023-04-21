if CLIENT then
	SWEP.PrintName			= "IDF Defender"
	SWEP.Author				= "Schwarz Kruppzo"
end

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("cs/sprites/galil_selecticon")
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicons_new.Add("weapon_cs16_galil", "cs/sprites/galil_killicon", Color(255, 255, 255, 255))
end

SWEP.Slot				= 0
SWEP.SlotPos			= 1

SWEP.Base 				= "weapon_cs_base"
SWEP.Weight				= CS16_GALIL_WEIGHT
SWEP.HoldType			= "ar2"

SWEP.Category			= "Counter-Strike"
SWEP.Spawnable			= true

--SWEP.PModel				= Model("models/weapons/cs16/p_galil.mdl")
SWEP.PModel				= Model("models/cs/p_galil.mdl")
SWEP.WModel				= Model("models/cs16/w_galil.mdl")
SWEP.VModel				= Model("models/weapons/cs16/c_galil.mdl")
--SWEP.VModel				= Model("models/cs/v_galil.mdl")

SWEP.ViewModel			= SWEP.VModel
SWEP.WorldModel			= SWEP.PModel

SWEP.Primary.Sound			= Sound("OldGalil.Shot1")
SWEP.Primary.EmptySound		= Sound("OldRifle.DryFire")
SWEP.Primary.ClipSize		= CS16_GALIL_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_GALIL_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_556NATO"
SWEP.Primary.Automatic		= true

SWEP.AnimPrefix 			= "ak47"
SWEP.MaxSpeed 				= CS16_GALIL_MAX_SPEED

if !gmod.GetGamemode().IsCStrike then
	SWEP.Slot			= 2
	SWEP.SlotPos		= 0
	SWEP.PModel			= Model("models/weapons/cs16/player/p_galil.mdl")
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
		self:GalilFire(0.04 + (0.3 * self:GetAccuracy()), 0.0875)
	elseif self.Owner:GetVelocity():Length2D() > 140 then
		self:GalilFire(0.04 + (0.07 * self:GetAccuracy()), 0.0875)
	else
		self:GalilFire(0.0375 * self:GetAccuracy(), 0.0875)
	end
end

function SWEP:FireAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

function SWEP:RecalculateAccuracy()
	self:SetAccuracy(((self:GetShotsFired() * self:GetShotsFired() * self:GetShotsFired()) / 200) + 0.35)
end

function SWEP:GalilFire(flSpread, flCycleTime)
	if self:Clip1() <= 0 then
		self:EmitSound(self.Primary.EmptySound)
		self:SetNextPrimaryFire(CurTime() + 0.2)

		return
	end

	self:SetDelayFire(true)
	self:SetShotsFired(self:GetShotsFired() + 1)
	self:RecalculateAccuracy()

	if self:GetAccuracy() > 1.25 then
		self:SetAccuracy(1.25)
	end

	self:FireAnimation()

	self:TakePrimaryAmmo(1)

	self:CS16_MuzzleFlash(22, 40)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self.Owner:FireBullets3(self, self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_GALIL_DISTANCE, CS16_GALIL_PENETRATION, "CS16_556NATO", CS16_GALIL_DAMAGE, CS16_GALIL_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex())

	self:EmitSound(self.Primary.Sound)

	self:CreateShell(1, "1")

	self:SetNextAttack(CurTime() + flCycleTime)
	self:SetTimeWeaponIdle(CurTime() + 1.9)

	if !self.Owner:IsOnGround() then
		self:KickBack(1.2, 0.5, 0.23, 0.15, 5.5, 3.5, 6)
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:KickBack(1.0, 0.45, 0.28, 0.045, 3.75, 3.0, 7)
	elseif self.Owner:Crouching() then
		self:KickBack(0.6, 0.3, 0.2, 0.0125, 3.25, 2.0, 7)
	else
		self:KickBack(0.65, 0.35, 0.25, 0.015, 3.5, 2.25, 7)
	end
end

function SWEP:Reload()
	if self:GetInReload() then
		return 
	end

	if CLIENT and !IsFirstTimePredicted() then 
		return 
	end

	if self:CS16_DefaultReload(CS16_GALIL_MAX_CLIP, ACT_VM_RELOAD, CS16_GALIL_RELOAD_TIME) then
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

if CLIENT then
	function SWEP:GetShellDir(attach)
		local ShellVelocity, ShellOrigin = Vector(), Vector()
		local velocity = self.Owner:GetVelocity()
		local punchangle = self.Owner:CS16_GetViewPunch()
		local angles = self.Owner:EyeAngles()
		angles.x = punchangle.x + angles.x
		angles.y = punchangle.y + angles.y

		ShellVelocity, ShellOrigin = CS16_GetDefaultShellInfo(self.Owner, attach, velocity, ShellVelocity, ShellOrigin, angles, 20, -8, self.ViewModelFlip and 10 or -10, false)

		return ShellOrigin, ShellVelocity, angles.y
	end
end