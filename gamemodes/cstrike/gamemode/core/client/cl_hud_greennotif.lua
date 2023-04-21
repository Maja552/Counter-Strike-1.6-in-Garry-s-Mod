
local font_info = {
	font = "Tahoma",
	extended = false,
	size = 36,
	weight = 500,
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
}
surface.CreateFont("cs_hud_greennotif", font_info)

local text_speed = 50
local text_fade_speed = 5
local text_fade_for = 2

local hit_last_one = false
local fade_until = 0
local notif_texts_tabs = {}
function StartGreenNotification(texts, instant)
    notif_texts_tabs = {}
    hit_last_one = false
    fade_until = 0

    for i,v in ipairs(texts) do
        surface.SetFont("cs_hud_greennotif")
        local texts_tab = {chars = {}, width = surface.GetTextSize(v)}
        local all_chars = string.ToTable(v)
        for k2,v2 in pairs(all_chars) do
            local alpha = 0
            if instant then alpha = 255 end
            table.ForceInsert(texts_tab.chars, {v2, surface.GetTextSize(v2), alpha})
        end
    
        table.ForceInsert(notif_texts_tabs, texts_tab)
    end

    for i,v in ipairs(notif_texts_tabs) do
        local last_x = (ScrW() - v.width) / 2
        local last_y = ScrH() / 1.4
        if i != 1 then
            last_y = last_y + 36
        end
        for i2,v2 in ipairs(v.chars) do
            if v2[1] != " " then
                v2[4] = {last_x, last_y}
                last_x = last_x + v2[2]
            else
                last_x = last_x + 12
            end
        end
    end
end

--StartGreenNotification({"You are out of ammunition", "Return to a buy zone to purchase more."})

local text_tab = {
    text = "",
    font = "cs_hud_greennotif",
    xalign = TEXT_ALIGN_LEFT,
    yalign = TEXT_ALIGN_CENTER,
    color = cs16_greennotif_color
}

function DrawGreenNotif()
    local num_of_ttabs = table.Count(notif_texts_tabs)
    for i,v in ipairs(notif_texts_tabs) do
        local num_of_chars = table.Count(v.chars)
        for i2,v2 in ipairs(v.chars) do
            text_tab.color = cs16_greennotif_color

            if hit_last_one then
                if fade_until < CurTime() then
                    v2[3] = v2[3] - text_fade_speed
                    if v2[3] < 1 then
                        notif_texts_tabs = {}
                        return
                    end
                end
            else
                local prev_char = v.chars[i2 - 1]
                if i > 1 and !prev_char then
                    local prev_tab = notif_texts_tabs[i - 1].chars
                    if prev_tab then
                        prev_char = prev_tab[#prev_tab]
                    end
                end
                 
                if v2[1] != " " then
                    if v2[3] < 255 and (!prev_char or prev_char[3] >= 255) then
                        v2[3] = math.Clamp(v2[3] + text_speed, 0, 255)
                    end
                elseif v2[3] < 255 and (!prev_char or prev_char[3] >= 255) then
                    v2[3] = 255
                end
                if num_of_ttabs == i and num_of_chars == i2 and v2[3] >= 255 then
                    fade_until = CurTime() + text_fade_for
                    hit_last_one = true
                end
            end
            text_tab.color.a = v2[3]

            if v2[4] then
                text_tab.text = v2[1]
                text_tab.pos = v2[4]
                draw.Text(text_tab)
            end
        end
    end
end
hook.Add("HUDPaint", "CS16_HUD_DrawGreenNotif", DrawGreenNotif)

print("Gamemode loaded cl_hud_greennotif.lua")