
surface.CreateFont("CS16_Upper_Notif", {
    font = "Arial",
    extended = false,
    size = 18,
    weight = 600,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
})

local notif_max_alpha = 255

local notif_tabs = {
    upper = {
        stage = 0,
        color = Color(255,255,255),
        alpha = 0,
        maxalpha = notif_max_alpha,
        waituntil = 0,
        text = "",
        pos = {ScrW() / 2, ScrH() / 4},
        xalign = TEXT_ALIGN_CENTER,
        yalign = TEXT_ALIGN_TOP
    },
    left = {
        stage = 0,
        color = Color(255,255,255),
        alpha = 0,
        maxalpha = notif_max_alpha,
        waituntil = 0,
        text = "",
        pos = {64, ScrH() / 2},
        xalign = TEXT_ALIGN_LEFT,
        yalign = TEXT_ALIGN_CENTER
    }
}

function StartDrawNotification(tab, for_seconds, text, color)
    tab = notif_tabs[tab]
    tab.stage = 1
    tab.alpha = 0
    tab.waituntil = CurTime() + for_seconds
    tab.text = text or ""
    tab.color = color or Color(255,255,255, tab.maxalpha)
end

net.Receive("cs16_notification", function()
    local tab = net.ReadString()
    local time = net.ReadFloat()
    local text = net.ReadString()
    local color = net.ReadColor()
    StartDrawNotification(tab, time, text, color)
end)

hook.Add("DrawOverlay", "cs16_notifs_DrawOverlay", function()
    for k,tab in pairs(notif_tabs) do
        if tab.stage > 0 then
            -- 1 STAGE - FADE IN
            if tab.stage == 1 then
                tab.alpha = math.Clamp(tab.alpha + 1, 0, tab.maxalpha)
                if tab.alpha == tab.maxalpha then
                    tab.stage = 2
                end

            -- 2 STAGE - HOLD
            elseif tab.stage == 2 then
                tab.alpha = tab.maxalpha
                if tab.waituntil < CurTime() then
                    tab.stage = 3
                end

            -- 3 STAGE - FADE OUT
            elseif tab.stage == 3 then
                tab.alpha = math.Clamp(tab.alpha - 1, 0, tab.maxalpha)
                if tab.alpha == 0 then
                    tab.stage = 0
                end
            end
            draw.Text({
                text = tab.text,
                pos = tab.pos,
                font = "CS16_Upper_Notif",
                xalign = tab.xalign,
                yalign = tab.yalign,
                color = Color(tab.color.r, tab.color.g, tab.color.b, tab.alpha)
            })
        end
end
end)

print("Gamemode loaded cl_hud_uppernotif.lua")