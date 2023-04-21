-- MODULE CONFIG
local roundstart_hook_name = "RoundModule_RoundStart"
local spectator_team = TEAM_SPECTATOR



-- MODULE: 3D flashlights
local flmodule_hook_prefix = "FlashlightModule_"
if SERVER then
    local plymeta = FindMetaTable("Player")

    hook.Add("PlayerInitialSpawn", flmodule_hook_prefix.."InitializeFlashlights", function(ply)
        ply.flashlightEnabled = false
        ply.flashlight3d = nil
        ply.nextFlashlightUse = 0
    end)

    hook.Add("PlayerDisconnected", flmodule_hook_prefix.."RemoveFlashlight1", function(ply)
        ply:ForceRemoveFlashlight()
    end)

    hook.Add("DoPlayerDeath", flmodule_hook_prefix.."RemoveFlashlight2", function(ply)
        ply:ForceRemoveFlashlight()
    end)

    hook.Add(round_hook_name, flmodule_hook_prefix.."RemoveFlashlights", function(ply)
        for k,v in pairs(player.GetAll()) do
            v:ForceRemoveFlashlight()
        end
    end)

    function plymeta:ForceUseFlashlight()
        if IsValid(self.flashlight3d) then
            self.flashlight3d:Remove()
        end

        if self.flashlightEnabled == false then
            self.flashlight3d = ents.Create("env_projectedtexture")
            self.flashlight3d:SetKeyValue("farz", 650)
            self.flashlight3d:SetKeyValue("nearz", 8)
            self.flashlight3d:SetKeyValue("lightfov", 60)
            self.flashlight3d:SetKeyValue("lightcolor", "255, 255, 255")
            self.flashlight3d:SetColor(Color(255, 255, 255))
            self:SetNWEntity("flashlight3d", self.flashlight3d)
        end

        self:EmitSound("gsttt/flashlight1.wav")
        
        self.flashlightEnabled = !self.flashlightEnabled
    end

    function plymeta:ForceRemoveFlashlight()
        if IsValid(self.flashlight3d) then
            self.flashlight3d:Remove()
        end
        self.flashlightEnabled = false
    end

    function GM:PlayerSwitchFlashlight(ply, enabled)
        if !ply:Alive() or ply:Team() == spectator_team or ply.nextFlashlightUse > CurTime() then return false end

        ply.nextFlashlightUse = CurTime() + 0.25
        ply:ForceUseFlashlight()

        return false
    end

    function Update3DFlashlights(ply)
        if IsValid(ply.flashlight3d) then
            ply.flashlight3d:SetPos(ply:EyePos() + ply:EyeAngles():Forward() * 15)
            ply.flashlight3d:SetAngles(ply:EyeAngles())
        end
    end
    hook.Add("PlayerPostThink", flmodule_hook_prefix.."Hook_Update3DFlashlights", Update3DFlashlights)
else
    hook.Add("CalcView", flmodule_hook_prefix.."CalcView", function(ply, position, angles, fov)
        local flashlight3d = ply:GetNWEntity("flashlight3d")
        if flashlight3d:IsValid() then
            flashlight3d:SetPos(ply:EyePos() + ply:EyeAngles():Forward() * 15)
            flashlight3d:SetAngles(ply:EyeAngles())
        end
    end)
end

print("Gamemode loaded module: 3D flashlights")