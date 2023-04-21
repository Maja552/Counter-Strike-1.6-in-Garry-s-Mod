
local hidehud = {
	CHudHealth = true,
	CHudBattery = true,
	CHudSecondaryAmmo = true,
	--CHudWeapon = true,
	CHudAmmo = true,
	CHudPoisonDamageIndicator = true,
	CHudSquadStatus = true,
	--CHudCrosshair = true
}

hook.Add("HUDShouldDraw", "CS16_HideHUD", function(name)
	if hidehud[name] then
		return !hidehud[name]
	end
	return true
end)

function DrawText(text, font, posx, posy, color, align)
	surface.SetFont(font)
	surface.SetTextColor(color.r, color.g, color.b, color.a)
	if align == true then
		local tw, th = surface.GetTextSize(text)
		tw = tw / 2
		th = th / 2
		surface.SetTextPos(posx - tw, posy - th)
	else
		surface.SetTextPos(posx, posy)
	end
	surface.DrawText(text)
end

function draw.Circle(x, y, radius, seg)
	local cir = {}

	table.insert(cir, { x = x, y = y, u = 0.5, v = 0.5 })
	for i = 0, seg do
		local a = math.rad((i / seg) * -360)
		table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })
	end

	local a = math.rad(0) -- This is needed for non absolute segment counts
	table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })

	surface.DrawPoly(cir)
end

function CreateCS16Button(x, y, parent, size_mul, text, text_pos, func_click, func_dclick, func_hover)
	local button = vgui.Create("DButton", parent)
	local bw = ui_button_w * size_mul
	local bh = ui_button_h * size_mul
	button:SetSize(bw, bh)
	button:SetPos(x, y)
	button:SetText("")

	local text_info = {
		text = text,
		--pos = {0, 0},
		pos = {bw / 2, bh / 2},
		font = "cs_menu_start_4",
		color = cs16_main_color,
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER
	}
	
	if text_pos == TEXT_ALIGN_LEFT then
		text_info.xalign = text_pos
		text_info.pos = {12 * size_mul, bh / 2}

	elseif text_pos == TEXT_ALIGN_RIGHT then
		text_info.xalign = text_pos
		text_info.pos = {bw - (12 * size_mul), bh / 2}
	end
	
	local hovered = false
	button.Think = function(self)
		if func_hover == nil then return end
		if self:IsHovered() then
			if !hovered then
				hovered = true
				func_hover(self)
			end
		else
			hovered = false
		end
	end

	button.Paint = function(self, w, h)
		local bgcolor = Color(15, 15, 15, 200)
		if self:IsHovered() then
			bgcolor = ui_button_hovered_color
		end
		draw.RoundedBox(0, 0, 0, w, h, bgcolor)
		surface.SetDrawColor(cs16_main_color.r, cs16_main_color.g, cs16_main_color.b, 25)
		surface.DrawLine(0, 0, w, 0)
		surface.DrawLine(0, 0, 0, h)
		surface.DrawLine(w-1, 0, w-1, h)
		surface.DrawLine(0, h-1, w, h-1)

		draw.Text(text_info)
	end
	if func_click then
		button.DoClick = function(self)
			func_click(self)
		end
	end
	if func_dclick then
		button.DoDoubleClick = function(self)
			func_dclick(self)
		end
	end
	return button
end

print("Gamemode loaded cl_hud_util.lua")