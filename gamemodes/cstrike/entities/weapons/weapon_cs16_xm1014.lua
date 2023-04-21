if CLIENT then
	SWEP.PrintName			= "Leone YG1265 Auto Shotgun"
	SWEP.Author				= "Schwarz Kruppzo"
end

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("cs/sprites/xm1014_selecticon")
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicons_new.Add("weapon_cs16_xm1014", "cs/sprites/xm1014_killicon", Color(255, 255, 255, 255))
end

SWEP.Slot				= 0
SWEP.SlotPos			= 1

SWEP.Base 				= "weapon_cs_base"
SWEP.Weight				= CS16_XM1014_WEIGHT
SWEP.HoldType			= "smg"

SWEP.Category			= "Counter-Strike"
SWEP.Spawnable			= true

--SWEP.PModel				= Model("models/weapons/cs16/p_xm1014.mdl")
SWEP.PModel				= Model("models/cs/p_xm1014.mdl")
SWEP.WModel				= Model("models/cs16/w_xm1014.mdl")
SWEP.VModel				= Model("models/weapons/cs16/v_xm1014.mdl")
--SWEP.VModel				= Model("models/cs/v_xm1014.mdl")

SWEP.ViewModel			= SWEP.VModel
SWEP.WorldModel			= SWEP.PModel

SWEP.Primary.Sound			= Sound("OldXM1014.Shot1")
SWEP.Primary.EmptySound		= Sound("OldRifle.DryFire")
SWEP.Primary.ClipSize		= CS16_XM1014_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_XM1014_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_BUCKSHOT"
SWEP.Primary.Automatic		= true

SWEP.AnimPrefix 			= "m249"
SWEP.MaxSpeed 				= CS16_XM1014_MAX_SPEED
SWEP.Price 					= 3000

if !gmod.GetGamemode().IsCStrike then
	SWEP.Slot			= 3
	SWEP.SlotPos		= 0
	SWEP.PModel			= Model("models/weapons/cs16/player/p_xm1014.mdl")
end

function SWEP:OnSetupDataTables()
	self:NetworkVar("Int", 1, "InSpecialReload")
	self:NetworkVar("Float", 6, "PumpTime")
	self:NetworkVar("Float", 7, "_nextFire")
end

function SWEP:OnDeploy()
	self:SendWeaponAnim(ACT_VM_DRAW)

	self:SetTimeWeaponIdle(CurTime() + 4)
end

function SWEP:PrimaryAttack()
	if self.Owner:WaterLevel() == 3 then
		self:EmitSound(self.Primary.EmptySound)
		self:SetNextPrimaryFire(CurTime() + 0.15)

		return
	end

	if CurTime() < self:Get_nextFire() then 
		return 
	end

	if self:Clip1() <= 0 then
		self:EmitSound(self.Primary.EmptySound)
		self:SetNextPrimaryFire(CurTime() + 0.2)

		return
	end

	self:SetDelayFire(true)
	self:SetShotsFired(self:GetShotsFired() + 6)
	self:FireAnimation()

	self:TakePrimaryAmmo(1)

	self:CS16_MuzzleFlash(21, 50)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	local tracedata = {}
	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos() + (self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch()):Forward() * 3000
	tracedata.mask = MASK_SHOT
	tracedata.filter = self.Owner
	local tr = util.TraceLine(tracedata)
	
	local currentDamage = 0
	if tr.Fraction != 1 then
		currentDamage = ((1 - tr.Fraction) * 20)
	end

	local shootAngles = self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch()
	local vecDirShooting = shootAngles:Forward()
	local vecRight = shootAngles:Right()
	local vecUp = shootAngles:Up()

	for i = 1, 6 do
		x = util.SharedRandom("SpreadX1"..i, -0.5, 0.5) + util.SharedRandom("SpreadX2"..i, -0.5, 0.5)
		y = util.SharedRandom("SpreadY1"..i, -0.5, 0.5) + util.SharedRandom("SpreadY2"..i, -0.5, 0.5)

		local vecDir = vecDirShooting + (x * 0.0725 * vecRight) + (y * 0.0725 * vecUp)
		vecDir:Normalize()

		local bullet = {}
		bullet.Num = 1
		bullet.Src = self.Owner:GetShootPos()
		bullet.Dir = vecDir
		bullet.Spread = Vector(0, 0, 0)
		bullet.Distance = 3000
		bullet.Tracer = 0
		bullet.Force = 2
		bullet.Damage = currentDamage
		bullet.AmmoType = "CS16_BUCKSHOT"
		bullet.Callback = cvars.Number("cs16_sv_impact") == 1 and CS16_BulletCallBack or nil
		self.Owner:FireBullets(bullet)
	end

	self:EmitSound(self.Primary.Sound)

	self:CreateShell(2, "1")

	if self:Clip1() > 0 then
		self:SetPumpTime(CurTime() + 0.125)
	end

	self:SetNextAttack(CurTime() + 0.25)
	self:SetTimeWeaponIdle(CurTime() + ((self:Clip1() > 0) and 2.25 or 0.75))
	self:SetInSpecialReload(0)

	if IsFirstTimePredicted() then
		local angle = self.Owner:CS16_GetViewPunch()
		angle.p = angle.p - (self.Owner:IsOnGround() and util.SharedRandom("PunchP", 3, 5) or util.SharedRandom("PunchP", 7, 10))

		self.Owner:CS16_SetViewPunch(angle)
	end
end

function SWEP:FireAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

function SWEP:Reload()
	local infinite_ammo = SUBGAMEMODE.CONFIG.INFINITE_AMMO
	if (!infinite_ammo and (self:Ammo1() <= 0)) or self:Clip1() == CS16_XM1014_MAX_CLIP then 
		return false
	end
	if self:GetNextPrimaryFire() > CurTime() then 
		return false
	end

	if self:GetInSpecialReload() == 0 then
		self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
		self:SetInSpecialReload(1)

		self:SetNextAttack(CurTime() + 0.55)
		self:SetTimeWeaponIdle(CurTime() + 0.55)
	elseif self:GetInSpecialReload() == 1 then
		if self:GetTimeWeaponIdle() > CurTime() then
			return false
		end

		self:SetInSpecialReload(2)
		self:SendWeaponAnim(ACT_VM_RELOAD)
		if self.VModel == "models/cs/v_xm1014.mdl" then
			self:EmitSound("weapons/m3_insertshell.wav")
		end

		self:SetTimeWeaponIdle(CurTime() + 0.3)
	else
		self:SetClip1(self:Clip1() + 1)
		if !infinite_ammo then
			self.Owner:RemoveAmmo(1, self.Primary.Ammo)
		end

		self:SetInSpecialReload(1)
		self:Set_nextFire(CurTime() + 0.1)
	end

	return true
end

function SWEP:WeaponIdle()
	if self:GetTimeWeaponIdle() > CurTime() then
		return
	end

	if self:GetPumpTime() != 0 and self:GetPumpTime() < CurTime() then
		self:SetPumpTime(0)
	end
	
	local can_reload = (self:Ammo1() > 0 or SUBGAMEMODE.CONFIG.INFINITE_AMMO)

	if self:GetTimeWeaponIdle() < CurTime() then
		if self:Clip1() == 0 and self:GetInSpecialReload() == 0 and can_reload then
			self:Reload()
		elseif self:GetInSpecialReload() != 0 then
			if self:Clip1() != CS16_XM1014_MAX_CLIP and can_reload then
				self:Reload()
			else
				self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
				self:SetInSpecialReload(0)
				self:SetTimeWeaponIdle(CurTime() + 1.5)
				self:Set_nextFire(0)
			end
		else
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
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

		ShellVelocity, ShellOrigin = CS16_GetDefaultShellInfo(self.Owner, attach, velocity, ShellVelocity, ShellOrigin, angles, 22, -9, self.ViewModelFlip and 11 or -11, false)

		return ShellOrigin, ShellVelocity, angles.y
	end
end