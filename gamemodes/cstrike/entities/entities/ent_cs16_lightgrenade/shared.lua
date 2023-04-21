ENT.Type			= "anim"
ENT.PrintName		= "Light Grenade"
ENT.Author			= "Schwarz Kruppzo"
ENT.AutomaticFrameAdvance = true

local function create_grenade_dlight(pos, ent)
    local dist = LocalPlayer():GetPos():Distance(pos)
    if dist < 1000 then
        ent.Dlight = DynamicLight(ent:EntIndex())
        ent.Dlight.pos = pos
        ent.Dlight.r = 191
        ent.Dlight.g = 255
        ent.Dlight.b = 241
        ent.Dlight.brightness = 3
        ent.Dlight.Decay = 5
        --ent.Dlight.Size = 200 - (dist / 6)
        ent.Dlight.Size = 220 - (dist / 10)
        ent.Dlight.DieTime = CurTime() + 1
        ent.Dlight.nomodel = false
    end
end

if CLIENT then
    function ENT:Think()
        if self:GetNWBool("Detonated", false) then
            create_grenade_dlight(self:GetPos() + Vector(0,0,30), self)
        end
    end
end
