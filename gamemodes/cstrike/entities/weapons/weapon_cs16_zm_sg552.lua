if CLIENT then
	SWEP.PrintName			= "Krieg 552"
	SWEP.Author				= "Schwarz Kruppzo"
end

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("cs/sprites/sg552_selecticon")
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicons_new.Add("weapon_cs16_sg552", "cs/sprites/sg552_killicon", Color(255, 255, 255, 255))
end

SWEP.Slot				= 0
SWEP.SlotPos			= 1

SWEP.Base 				= "weapon_cs_base"
SWEP.Weight				= CS16_SG552_WEIGHT
SWEP.HoldType			= "ar2"

SWEP.Category			= "Counter-Strike"
SWEP.Spawnable			= true

--SWEP.PModel				= Model("models/weapons/cs16/p_sg552.mdl")
SWEP.PModel				= Model("models/cs/p_sg552.mdl")
SWEP.WModel				= Model("models/cs16/w_sg552.mdl")
SWEP.VModel				= Model("models/weapons/cs16/c_sg552.mdl")
--SWEP.VModel				= Model("models/cs/v_sg552.mdl")

SWEP.ViewModel			= SWEP.VModel
SWEP.WorldModel			= SWEP.PModel

SWEP.Primary.Sound			= Sound("OldSG552.Shot1")
SWEP.Primary.EmptySound		= Sound("OldRifle.DryFire")
SWEP.Primary.ClipSize		= CS16_SG552_MAX_CLIP + 10
SWEP.Primary.DefaultClip	= CS16_SG552_MAX_CLIP + 10
SWEP.Primary.Ammo			= "CS16_556NATO"
SWEP.Primary.Automatic		= true

SWEP.AnimPrefix 			= "mp5"
SWEP.MaxSpeed 				= CS16_SG552_MAX_SPEED

if !gmod.GetGamemode().IsCStrike then
	SWEP.Slot			= 2
	SWEP.SlotPos		= 0
	SWEP.PModel			= Model("models/weapons/cs16/player/p_sg552.mdl")
end

function SWEP:OnSetupDataTables()
	self:NetworkVar("Bool", 5, "IsInScope")
end

function SWEP:OnDeploy()
	self:SendWeaponAnim(ACT_VM_DRAW)

	self:SetAccuracy(0.2)
	self:SetTimeWeaponIdle(CurTime() + 1.5)
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:SG552Fire(0.035 + (0.45 * self:GetAccuracy()), 0.0825)
	elseif self.Owner:GetVelocity():Length2D() > 140 then
		self:SG552Fire(0.035 + (0.075 * self:GetAccuracy()), 0.0825)
	elseif !self:GetIsInScope() then
		self:SG552Fire(0.02 * self:GetAccuracy(), 0.0825)
	else
		self:SG552Fire(0.02 * self:GetAccuracy(), 0.135)
	end
end

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextSecondaryFire() then 
		return
	end

	self:SetIsInScope(!self:GetIsInScope())

	self:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:FireAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

function SWEP:RecalculateAccuracy()
	self:SetAccuracy(((self:GetShotsFired() * self:GetShotsFired() * self:GetShotsFired()) / 220) + 0.3)
end

function SWEP:SG552Fire(flSpread, flCycleTime)
	if self:Clip1() <= 0 then
		self:EmitSound(self.Primary.EmptySound)
		self:SetNextPrimaryFire(CurTime() + 0.2)

		return
	end

	self:SetDelayFire(true)
	self:SetShotsFired(self:GetShotsFired() + 1)
	self:RecalculateAccuracy()

	if self:GetAccuracy() > 1 then
		self:SetAccuracy(1)
	end

	self:FireAnimation()

	self:TakePrimaryAmmo(1)

	self:CS16_MuzzleFlash(22, 30)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self.Owner:FireBullets3(self, self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_SG552_DISTANCE, CS16_SG552_PENETRATION, "CS16_556NATO", CS16_SG552_DAMAGE, CS16_SG552_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex())

	self:EmitSound(self.Primary.Sound)

	self:CreateShell(1, "1")

	self:SetNextAttack(CurTime() + flCycleTime)
	self:SetTimeWeaponIdle(CurTime() + 2)

	if self.Owner:GetVelocity():Length2D() > 0 then
		self:KickBack(1.0, 0.45, 0.28, 0.04, 4.25, 2.5, 7)
	elseif !self.Owner:IsOnGround() then
		self:KickBack(1.25, 0.45, 0.22, 0.18, 6.0, 4.0, 5)
	elseif self.Owner:Crouching() then
		self:KickBack(0.6, 0.35, 0.2, 0.0125, 3.7, 2.0, 10)
	else
		self:KickBack(0.625, 0.375, 0.25, 0.0125, 4.0, 2.25, 9)
	end
end

function SWEP:Reload()
	if self:GetInReload() then
		return 
	end

	if CLIENT and !IsFirstTimePredicted() then 
		return 
	end

	if self:CS16_DefaultReload(CS16_SG552_MAX_CLIP, ACT_VM_RELOAD, CS16_SG552_RELOAD_TIME) then
		self:SetAccuracy(0.2)
		self:SetShotsFired(0)
		self:SetDelayFire(false)
		self:SetIsInScope(false)
	end
end

function SWEP:WeaponIdle()
	if self:GetTimeWeaponIdle() > CurTime() then
		return
	end

	self:SetTimeWeaponIdle(CurTime() + 20)
	self:SendWeaponAnim(ACT_VM_IDLE)
end

function SWEP:OnHolster()
	self:SetIsInScope(false)
end

function SWEP:GetMaxSpeed()
	return self:GetIsInScope() and CS16_SG552_MAX_SPEED_ZOOM or CS16_SG552_MAX_SPEED
end

if CLIENT then
	function SWEP:OnCalcView(ply, pos, ang, fov)
		if self:GetIsInScope() then
			fov = 45.83
		end

		return fov
	end

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

function SWEP:ShouldDrawViewModel()
	return (self:GetScopeZoom() == 0)
end
