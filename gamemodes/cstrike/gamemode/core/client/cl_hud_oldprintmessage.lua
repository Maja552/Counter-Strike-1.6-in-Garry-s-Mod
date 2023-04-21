
local font_info = {
	font = "Verdana",
	extended = false,
	size = 20,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
}

surface.CreateFont("cs_hud_prntmsg", font_info)

local draw_until = 0
local text_msg = {}
function StartOldPrintMessage(text)
    draw_until = CurTime() + 2
    text_msg = text
end

local text_tab = {
    text = "",
    font = "cs_hud_prntmsg",
    xalign = TEXT_ALIGN_CENTER,
    yalign = TEXT_ALIGN_CENTER,
    color = cs16_main_color
}

function DrawOldPrintMessage()
    if draw_until > CurTime() then
		--chat.AddText(text_msg .." ".. draw_until - CurTime())
		local last_y = ScrH() / 2.5
		for k,v in pairs(text_msg) do
			text_tab.pos = {ScrW() / 2, last_y}
			text_tab.text = v
			draw.Text(text_tab)
			last_y = last_y + 24
		end
    end
end
hook.Add("HUDPaint", "CS16_HUD_DrawOldPrintMessage", DrawOldPrintMessage)


print("Gamemode loaded cl_hud_oldprintmessage.lua")