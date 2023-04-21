if CLIENT then
	SWEP.PrintName			= "Krieg 550 Commando"
	SWEP.Author				= "Schwarz Kruppzo"
end

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("cs/sprites/sg550_selecticon")
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicons_new.Add("weapon_cs16_sg550", "cs/sprites/sg550_killicon", Color(255, 255, 255, 255))
end

SWEP.Slot				= 0
SWEP.SlotPos			= 1

SWEP.Base 				= "weapon_cs_base"
SWEP.Weight				= CS16_SG550_WEIGHT
SWEP.HoldType			= "ar2"

SWEP.Category			= "Counter-Strike"
SWEP.Spawnable			= true


--SWEP.PModel				= Model("models/weapons/cs16/p_sg550.mdl")
SWEP.PModel				= Model("models/cs/p_sg550.mdl")
SWEP.WModel				= Model("models/cs16/w_sg550.mdl")
SWEP.VModel				= Model("models/weapons/cs16/v_sg550.mdl")
--SWEP.VModel				= Model("models/cs/v_sg550.mdl")

SWEP.ViewModel			= SWEP.VModel
SWEP.WorldModel			= SWEP.PModel

SWEP.Primary.Sound			= Sound("OldSG550.Shot1")
SWEP.Primary.EmptySound		= Sound("OldRifle.DryFire")
SWEP.Primary.ClipSize		= CS16_SG550_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_SG550_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_556NATO"
SWEP.Primary.Automatic		= true

SWEP.AnimPrefix 			= "rifle"
SWEP.MaxSpeed 				= CS16_SG550_MAX_SPEED

if !gmod.GetGamemode().IsCStrike then
	SWEP.Slot			= 2
	SWEP.SlotPos		= 0
	SWEP.PModel			= Model("models/weapons/cs16/player/p_sg550.mdl")
end

function SWEP:OnSetupDataTables()
	self:NetworkVar("Int", 1, "ScopeZoom")
end

function SWEP:OnDeploy()
	self:SendWeaponAnim(ACT_VM_DRAW)

	self:SetTimeWeaponIdle(CurTime() + 3)
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:SG550Fire(0.45 * (1 - self:GetAccuracy()), 0.25)
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:SG550Fire(0.15, 0.25)
	elseif self.Owner:Crouching() then
		self:SG550Fire(0.04 * (1 - self:GetAccuracy()), 0.25)
	else
		self:SG550Fire(0.05 * (1 - self:GetAccuracy()), 0.25)
	end
end

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextSecondaryFire() or CurTime() < self:GetNextPrimaryFire() then 
		return
	end

	if self:GetScopeZoom() == 0 then
		self:SetScopeZoom(1)
	elseif self:GetScopeZoom() == 1 then
		self:SetScopeZoom(2)
	else
		self:SetScopeZoom(0)
	end

	if SERVER then
		self.Owner:EmitSound("weapons/zoom.wav")
	end

	self:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:FireAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

function SWEP:SG550Fire(flSpread, flCycleTime)
	if self:GetScopeZoom() == 0 then
		flSpread = flSpread + 0.025
	end

	if self:GetLastFire() != 0 then
		self:SetAccuracy(math.min((CurTime() - self:GetLastFire()) * 0.35 + 0.65, 0.98))
		self:SetLastFire(CurTime())
	end

	self:SetLastFire(CurTime())

	if self:Clip1() <= 0 then
		self:EmitSound(self.Primary.EmptySound)
		self:SetNextPrimaryFire(CurTime() + 0.2)

		return
	end

	self:FireAnimation()
	self:TakePrimaryAmmo(1)

	self:CS16_MuzzleFlash(22, 30)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self.Owner:FireBullets3(self, self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_SG550_DISTANCE, CS16_SG550_PENETRATION, "CS16_556NATO", CS16_SG550_DAMAGE, CS16_SG550_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex())

	self:EmitSound(self.Primary.Sound)

	self:CreateShell(1, "1")

	self:SetNextAttack(CurTime() + flCycleTime)
	self:SetTimeWeaponIdle(CurTime() + 1.8)

	if IsFirstTimePredicted() then
		local angle = self.Owner:CS16_GetViewPunch()
		angle.p = angle.p - util.SharedRandom("PunchP", 0.75, 1.25) + angle.p * 0.25
		angle.y = angle.y + util.SharedRandom("PunchY", -0.75, 0.75)

		self.Owner:CS16_SetViewPunch(angle)
	end
end

function SWEP:WeaponIdle()
	if self:GetTimeWeaponIdle() > CurTime() then
		return
	end

	if self:Clip1() != 0 then 
		self:SetTimeWeaponIdle(CurTime() + 60)
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
end

function SWEP:IsSniperRifle()
	return true
end

function SWEP:Reload()
	if self:GetInReload() then
		return 
	end

	if CLIENT and !IsFirstTimePredicted() then 
		return 
	end

	if self:CS16_DefaultReload(CS16_SG550_MAX_CLIP, ACT_VM_RELOAD, CS16_SG550_RELOAD_TIME) then
		self:SetScopeZoom(0)
	end
end

function SWEP:GetMaxSpeed()
	return self:GetScopeZoom() == 0 and CS16_SG550_MAX_SPEED or CS16_SG550_MAX_SPEED_ZOOM
end

function SWEP:AdjustMouseSensitivity()
	local var = {[0] = 1, [1] = 0.444, [2] = 0.16}
	return var[self:GetScopeZoom()] or 1
end

function SWEP:OnHolster()
	self:SetScopeZoom(0)
end

if CLIENT then
	function SWEP:OnCalcView(ply, pos, ang, fov)
		if self:GetScopeZoom() == 1 then
			fov = 33.3
		elseif self:GetScopeZoom() == 2 then
			fov = 12.5
		end

		return fov
	end

	function SWEP:OnPreViewModelDraw()
		if self:GetScopeZoom() != 0 then
			render.SetBlend(0)
		end
	end
	
	function SWEP:GetShellDir(attach)
		local ShellVelocity, ShellOrigin = Vector(), Vector()
		local velocity = self.Owner:GetVelocity()
		local punchangle = self.Owner:CS16_GetViewPunch()
		local angles = self.Owner:EyeAngles()
		angles.x = punchangle.x + angles.x
		angles.y = punchangle.y + angles.y

		ShellVelocity, ShellOrigin = CS16_GetDefaultShellInfo(self.Owner, attach, velocity, ShellVelocity, ShellOrigin, angles, self.ViewModelFlip and 20 or 17, -8, self.ViewModelFlip and 10 or -10, false)

		return ShellOrigin, ShellVelocity, angles.y
	end
end

function SWEP:ShouldDrawViewModel()
	return (self:GetScopeZoom() == 0)
end
