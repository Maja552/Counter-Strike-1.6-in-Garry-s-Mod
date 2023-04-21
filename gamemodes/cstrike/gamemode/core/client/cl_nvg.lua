
local next_nvg_toggle = 0

function NVG_Toggle()
    if next_nvg_toggle > CurTime() then return end
    next_nvg_toggle = CurTime() + 1

    local client = LocalPlayer()
    if client:GetNWBool("HasNVG", false) then
        client.CS16_NVG_ENABLED = !client.CS16_NVG_ENABLED
        if client.CS16_NVG_ENABLED then
            surface.PlaySound("cstrike/items/nvg_on.wav")
        else
            surface.PlaySound("cstrike/items/nvg_off.wav")
        end
    else
        client.CS16_NVG_ENABLED = false
    end

    net.Start("cs16_togglenvg")
        net.WriteBool(client.CS16_NVG_ENABLED)
    net.SendToServer()
end

concommand.Add("nightvision", function()
    NVG_Toggle()
end)

net.Receive("cs16_togglenvg", function(len)
    local ply = net.ReadEntity()
    --if ply != LocalPlayer() then
        ply.CS16_NVG_ENABLED = net.ReadBool()
        --print(ply, " toggled nvg: ", ply.CS16_NVG_ENABLED)
    --end
end)

local mat_color = Material("pp/colour")
hook.Add("RenderScreenspaceEffects", "cs16_nvg_effects", function()
    local client = LocalPlayer()

    local nvg_info = SUBGAMEMODE:NVG_EFFECTS()
    if !istable(nvg_info) then return end

    render.UpdateScreenEffectTexture()
    mat_color:SetTexture("$fbtexture", render.GetScreenEffectTexture())
    mat_color:SetFloat("$pp_colour_brightness", nvg_info.brightness)
    mat_color:SetFloat("$pp_colour_contrast", nvg_info.contrast)
    mat_color:SetFloat("$pp_colour_colour", nvg_info.colour)
    mat_color:SetFloat("$pp_colour_mulr", nvg_info.clr_r)
    mat_color:SetFloat("$pp_colour_mulg", nvg_info.clr_g)
    mat_color:SetFloat("$pp_colour_mulb", nvg_info.clr_b)
    mat_color:SetFloat("$pp_colour_addr", nvg_info.add_r)
    mat_color:SetFloat("$pp_colour_addg", nvg_info.add_g)
    mat_color:SetFloat("$pp_colour_addb", nvg_info.add_b)
    
    render.SetMaterial(mat_color)
    render.DrawScreenQuad()
end)

print("Gamemode loaded cl_nvg.lua")