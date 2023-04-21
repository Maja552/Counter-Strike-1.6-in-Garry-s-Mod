
net.Receive("cs16_cloakplayer", function(len)
    local ent = net.ReadEntity()
    local dur = net.ReadInt(16)
    ent.cloaked_til = CurTime() + dur

    if ent == LocalPlayer() then
        next_cloak_sound = ent.cloaked_til - 0.15
    end
end)

net.Receive("cs16_freezeplayer", function(len)
    local ent = net.ReadEntity()
    local dur = net.ReadInt(16)
    ent.frozen_for = CurTime() + dur
end)

net.Receive("cs16_usesound", function(len)
    surface.PlaySound("cstrike/common/wpn_select.wav")
    next_click_sound = CurTime() + 0.5
end)

net.Receive("cs16_greennotification", function(len)
    local texts = net.ReadTable()
    StartGreenNotification(texts)
end)

net.Receive("cs16_oldprintmessage", function(len)
    local text = net.ReadTable()
    StartOldPrintMessage(text)
end)

net.Receive("cs16_droppedweapon", function(len)
    local ent = net.ReadEntity()
    local ply = net.ReadEntity()
    ent:OnCS16DropSH(ply)
end)

net.Receive("cs16_planted_c4", function(len)
    surface.PlaySound("cstrike/radio/bombpl.wav")
end)

net.Receive("cs16_updateteam", function(len)
    local ent = net.ReadEntity()
    local team_id = net.ReadInt(8)
    ent.cs16_team = team_id
end)

net.Receive("cs16_updateallteams", function(len)
    local tab = net.ReadTable()

    for k,v in pairs(tab) do
        v[1].cs16_team = v[2]
    end
end)

net.Receive("cs16_change_team", function(len)
    timer.Remove("model_selection_delay")
    current_start_menu = "select_model"
    CreateStartMenu()
end)

print("Gamemode loaded cl_networking.lua")