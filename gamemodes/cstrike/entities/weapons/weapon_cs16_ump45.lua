if CLIENT then
	SWEP.PrintName			= "KM UMP45"
	SWEP.Author				= "Schwarz Kruppzo"
end

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("cs/sprites/ump45_selecticon")
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicons_new.Add("weapon_cs16_ump45", "cs/sprites/ump45_killicon", Color(255, 255, 255, 255))
end

SWEP.Slot				= 0
SWEP.SlotPos			= 1

SWEP.Base 				= "weapon_cs_base"
SWEP.Weight				= CS16_UMP45_WEIGHT
SWEP.HoldType			= "smg"

SWEP.Category			= "Counter-Strike"
SWEP.Spawnable			= true

--SWEP.PModel				= Model("models/weapons/cs16/p_ump45.mdl")
SWEP.PModel				= Model("models/cs/p_ump45.mdl")
SWEP.WModel				= Model("models/cs16/w_ump45.mdl")
SWEP.VModel				= Model("models/weapons/cs16/c_ump45.mdl")
--SWEP.VModel				= Model("models/cs/v_ump45.mdl")

SWEP.ViewModel			= SWEP.VModel
SWEP.WorldModel			= SWEP.PModel

SWEP.Primary.Sound			= Sound("OldUMP45.Shot1")
SWEP.Primary.EmptySound		= Sound("OldRifle.DryFire")
SWEP.Primary.ClipSize		= CS16_UMP45_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_UMP45_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_45ACP"
SWEP.Primary.Automatic		= true

SWEP.AnimPrefix 			= "carbine"
SWEP.MaxSpeed 				= CS16_UMP45_MAX_SPEED
SWEP.Price 					= 1700

if !gmod.GetGamemode().IsCStrike then
	SWEP.Slot			= 2
	SWEP.SlotPos		= 0
	SWEP.PModel			= Model("models/weapons/cs16/player/p_ump45.mdl")
end

function SWEP:OnDeploy()
	self:SendWeaponAnim(ACT_VM_DRAW)

	self:SetAccuracy(0.2)
	self:SetTimeWeaponIdle(CurTime() + 1.5)
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:UMP45Fire(0.24 * self:GetAccuracy(), 0.1)
	else
		self:UMP45Fire(0.04 * self:GetAccuracy(), 0.1)
	end
end

function SWEP:FireAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

function SWEP:RecalculateAccuracy()
	self:SetAccuracy(((self:GetShotsFired() * self:GetShotsFired()) / 210) + 0.5)
end

function SWEP:UMP45Fire(flSpread, flCycleTime)
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

	self:CS16_MuzzleFlash(11, 40)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self.Owner:FireBullets3(self, self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(CLIENT), flSpread, CS16_UMP45_DISTANCE, CS16_UMP45_PENETRATION, "CS16_45ACP", CS16_UMP45_DAMAGE, CS16_UMP45_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex())

	self:EmitSound(self.Primary.Sound)

	self:CreateShell(0, "1")

	self:SetNextAttack(CurTime() + flCycleTime)
	self:SetTimeWeaponIdle(CurTime() + 2)

	if !self.Owner:IsOnGround() then
		self:KickBack(0.125, 0.65, 0.55, 0.0475, 5.5, 4.0, 10)
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:KickBack(0.55, 0.3, 0.225, 0.03, 3.5, 2.5, 10)
	elseif self.Owner:Crouching() then
		self:KickBack(0.25, 0.175, 0.125, 0.02, 2.25, 1.25, 10)
	else
		self:KickBack(0.275, 0.2, 0.15, 0.0225, 2.5, 1.5, 10)
	end
end

function SWEP:Reload()
	if self:GetInReload() then
		return 
	end

	if CLIENT and !IsFirstTimePredicted() then 
		return 
	end

	if self:CS16_DefaultReload(CS16_UMP45_MAX_CLIP, ACT_VM_RELOAD, CS16_UMP45_RELOAD_TIME) then
		self:SetAccuracy(0.2)
		self:SetShotsFired(0)
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

		ShellVelocity, ShellOrigin = CS16_GetDefaultShellInfo(self.Owner, attach, velocity, ShellVelocity, ShellOrigin, angles, 34, -10, self.ViewModelFlip and 11 or -11, false)

		return ShellOrigin, ShellVelocity, angles.y
	end
end