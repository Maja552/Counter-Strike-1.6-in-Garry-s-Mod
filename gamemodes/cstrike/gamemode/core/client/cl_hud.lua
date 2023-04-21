
surface.CreateFont("cs16_hud_css", {
	font = "csd",
	extended = true,
	size = 40,
	weight = 400
})
surface.CreateFont("cs16_cstrike_font", {
	font = "CloseCaption_Bold",
	extended = true,
	size = 20,
	weight = 1000,
	additive = true
})
surface.CreateFont("cs16_hud_time", {
	font = "CloseCaption_Bold",
	extended = true,
	size = 26,
	weight = 10000,
	additive = true,
})
surface.CreateFont("cs16_hud_time2", {
	font = "CloseCaption_Bold",
	extended = true,
	size = 26,
	weight = 10000,
	additive = true,
	blursize = 1,
	scanlines = 0,
})


local cstrike_font = {
	["0"] =			{x = 0, 	y = 0,		w = 20,		h = 24},
	["1"] =			{x = 24, 	y = 0,		w = 20,		h = 24},
	["2"] =			{x = 48, 	y = 0, 		w = 20,		h = 24},
	["3"] =			{x = 72, 	y = 0, 		w = 20,		h = 24},
	["4"] =			{x = 96, 	y = 0, 		w = 20,		h = 24},
	["5"] =			{x = 120, 	y = 0, 		w = 20, 	h = 24},
	["6"] =			{x = 144, 	y = 0, 		w = 20,		h = 24},
	["7"] =			{x = 168, 	y = 0, 		w = 20,		h = 24},
	["8"] =			{x = 192, 	y = 0, 		w = 20,		h = 24},
	["9"] =			{x = 216, 	y = 0, 		w = 20,		h = 24},
	["separator"] =	{x = 240, 	y = 0, 		w = 2,		h = 24}, -- separator
	["shield1"] =	{x = 0, 	y = 25, 	w = 24,		h = 23}, -- shield - full
	["c"] =			{x = 24, 	y = 25, 	w = 24,		h = 23}, -- shield - empty
	["cross"] =		{x = 48, 	y = 25, 	w = 23,		h = 23}, -- cross
	["e"] =			{x = 0, 	y = 72, 	w = 24,		h = 24}, -- 12 gauge ammo
	["ammo_50"] =	{x = 24, 	y = 72, 	w = 24,		h = 24}, -- .50 ammo
	["ammo_9mm"] =	{x = 48, 	y = 72, 	w = 24,		h = 24}, -- 9mm ammo
	["h"] =			{x = 72, 	y = 72, 	w = 24,		h = 24}, -- 7.62 ammo
	["i"] =			{x = 96, 	y = 72, 	w = 24,		h = 24}, -- .45 ammo
	["ammo_357"] =	{x = 120, 	y = 72, 	w = 24,		h = 24}, -- .357 ammo
	["clock"] =		{x = 144, 	y = 72, 	w = 24,		h = 24}, -- clock
	["l"] =			{x = 168,	y = 72,		w = 20,		h = 20}, -- slot 1
	["m"] =			{x = 188,	y = 72,		w = 20,		h = 20}, -- slot 2
	["n"] =			{x = 208,	y = 72,		w = 20,		h = 20}, -- slot 3
	["o"] =			{x = 168,	y = 92,		w = 20,		h = 20}, -- slot 4
	["p"] =			{x = 188,	y = 92,		w = 20,		h = 20}, -- slot 5
	["r"] =			{x = 208,	y = 92,		w = 20,		h = 20}, -- empty box
	["dollar"] =	{x = 192,	y = 25,		w = 19,		h = 25}, -- empty box
}

local function cs16_texture_uv(x, y, sprite_x, sprite_y, sprite_width, sprite_height, image_width, image_height)
	surface.DrawTexturedRectUV(x, y, sprite_width, sprite_height, sprite_x / image_width, sprite_y / image_height, (sprite_x + sprite_width) / image_width, (sprite_y + sprite_height) / image_height)
end

function CStrikeFont(x, y, align_x, align_y, text, color_to_use)
	local pos_x = x
	local pos_y = y
	local new_text = {}
	local size_x = 0
	local size_y = 0
	for k,v in pairs(text) do
		local cur_char = cstrike_font[v]
		if isnumber(v) then
			pos_x = pos_x + v
			size_x = size_x + v
		elseif cur_char != nil then
			--cs16_texture_uv(pos_x, pos_y, cur_char.x, cur_char.y, cur_char.w, cur_char.h, 256, 256)
			table.ForceInsert(new_text, {
				pos_x = pos_x,
				pos_y = pos_y,
				char_x = cur_char.x,
				char_y = cur_char.y,
				char_w = cur_char.w,
				char_h = cur_char.h,
			})
			pos_x = pos_x + cur_char.w
			size_x = size_x + cur_char.w
			if size_y < cur_char.h then
				size_y = cur_char.h
			end
		else
			table.ForceInsert(new_text, v)
			pos_x = pos_x + 8
		end
	end
	local add_x = 0
	local add_y = 0
	if align_x == TEXT_ALIGN_CENTER then
		add_x = -(size_x / 2)
	elseif align_x == TEXT_ALIGN_RIGHT then
		add_x = -size_x
	end
	
	if align_y == TEXT_ALIGN_CENTER then
		add_y = -(size_y / 2)
	elseif align_y == TEXT_ALIGN_BOTTOM then
		add_y = -size_y
	end
	surface.SetDrawColor(color_to_use)
	for i,v in ipairs(new_text) do
		if isstring(v) then
			local posx = 0
			local posy = 0
			if new_text[i-1] and new_text[i+1] then
				posx = (new_text[i-1].pos_x + add_x) + ((new_text[i+1].pos_x + add_x) - (new_text[i-1].pos_x + add_x)) - 8
				posy = new_text[i-1].pos_y + add_y
			end
			draw.Text({
				text = v,
				font = "cs16_cstrike_font",
				pos = {posx, posy},
				--xalign = align_x,
				--yalign = align_y,
				color = color_to_use
			})
		else
			cs16_texture_uv(v.pos_x + add_x, v.pos_y + add_y, v.char_x, v.char_y, v.char_w, v.char_h, 256, 256)
		end
	end
end

local function cstrike_num_to_tab(num)
	if num == 0 then return {"0"} end
	num = tostring(num)
	local tab = {}
	for i=1, #num do
		table.ForceInsert(tab, num[i])
	end
	return tab
end


our_cs16_money = 0
next_money_update = 0

cs16_hud_normal_color = Color(255, 180, 0, 100)
cs16_hud_ammo_color = Color(255, 180, 0, 100)
local ammo_alpha_target = 100
local ammo_alpha_target_stage = 0
local ammo_alpha_target_end = 0

cs16_hud_money_color = Color(200, 180, 0, 100)
cs16_hud_low_color = Color(255, 0, 0, 255)

local next_time_blink = 0
local time_blink_status = false

local cs_hud_texture = surface.GetTextureID("cs16/cs_hud")
hook.Add("HUDPaint", "CS16_HUD", function()
	local client = LocalPlayer()
	if client:IsSpectator() then return end

	surface.SetTexture(cs_hud_texture)
	surface.SetDrawColor(cs16_hud_normal_color)

	local money = {"dollar", 15}
	table.Add(money, cstrike_num_to_tab(client:GetMoney()))

	local time = {"clock", 15}
	table.Add(time, cstrike_num_to_tab(string.ToMinutesSeconds(game_state_time_left)))
	
	local time_color = cs16_hud_normal_color

	if game_state_time_left < 11 and game_state != GAMESTATE_NOTSTARTED then
		local speed = 0.2
		if game_state_time_left < 5 then
			speed = 0.1
		end
		if next_time_blink < CurTime() then
			next_time_blink = CurTime() + speed
			time_blink_status = !time_blink_status
		end
	else
		time_blink_status = false
	end

	if game_state_time_left == 0 or time_blink_status then
		time_color = Color(255,0,0)
	end

	-- CS 1.6 HUD
	CStrikeFont(ScrW() * 0.5, ScrH() - 14, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, time, time_color)

	if client:Alive() and !client:IsSpectator() then
		CStrikeFont(ScrW() - 10 * GSRCHUD:GetHUDScale(), ScrH() - 14 - 37, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, money, cs16_hud_money_color)
	end

	/*
	local H = ScrH() * 0.107
	for k,v in pairs(GetKillfeed()) do
		DrawKillfeed(k, ScrW() - 40, H + 32 + ((k - 1) * 36))
	end
	*/
end)


print("Gamemode loaded cl_hud.lua")