
local font_info = {
	font = "Verdana",
	extended = false,
	size = 20,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = false,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
}

local last_size_mul = 0
local sm16 = 0
local sm32 = 0
local sm64 = 0
local ud_panels_h = 0
local info_gap_pos = 0
local main_hud_color = sb_color_main

hook.Add("HUDPaint", "CS16_HUD_SPECTATOR", function()
	if !GM_INITIALIZED or IsValid(startmenu_frame) then return end
	local client = LocalPlayer()
	if !client:IsSpectator() then return end

	local scrw = ScrW()
	local scrh = ScrH()
	local size_mul = math.Clamp(scrh / 1080, 0.5, 1.2)

	if last_size_mul != size_mul then
		last_size_mul = size_mul
		sm16 = 16 * size_mul
		sm32 = 32 * size_mul
		sm64 = 64 * size_mul
		ud_panels_h = 144 * size_mul
		info_gap_pos = 120 * size_mul
		main_hud_color = sb_color_main
		
		font_info.size = 20 * size_mul
		surface.CreateFont("cs_hud_spect_1", font_info)
	end

	draw.RoundedBox(0, 0, 0, scrw, ud_panels_h, Color(0, 0, 0, 225))
	draw.RoundedBox(0, 0, scrh - ud_panels_h + 1, scrw, ud_panels_h, Color(0, 0, 0, 225))

	--if game_state != GAMESTATE_NOTSTARTED then
		local player_lists = SUBGAMEMODE.CONFIG.HUD_Spect_PlayerLists or {}
		local last_y = sm32

		for k,v in pairs(player_lists) do
			draw.Text({
				text = v(),
				pos = {scrw - info_gap_pos - sm16, last_y},
				font = "cs_hud_spect_1",
				color = main_hud_color,
				xalign = TEXT_ALIGN_RIGHT,
				yalign = TEXT_ALIGN_CENTER
			})
			last_y = last_y + (24 * size_mul)
		end

		local line_len = math.Clamp(last_y - (16 * size_mul), ud_panels_h * 0.5, last_y)

		surface.SetDrawColor(main_hud_color.r, main_hud_color.g, main_hud_color.b, main_hud_color.a)
		surface.DrawLine(scrw - info_gap_pos, 26 * size_mul, scrw - info_gap_pos, line_len)

		if SUBGAMEMODE.CONFIG.BUYING_ENABLED then
			draw.Text({
				text = "$"..tostring(client:GetMoney() or 0),
				pos = {scrw - info_gap_pos + sm16, sm32},
				font = "cs_hud_spect_1",
				color = main_hud_color,
				xalign = TEXT_ALIGN_LEFT,
				yalign = TEXT_ALIGN_CENTER
			})
		end

		draw.Text({
			text = string.ToMinutesSeconds(game_state_time_left),
			pos = {scrw - info_gap_pos + sm16, sm64},
			font = "cs_hud_spect_1",
			color = main_hud_color,
			xalign = TEXT_ALIGN_LEFT,
			yalign = TEXT_ALIGN_CENTER
		})

		local observer_target = client:GetObserverTarget()
		if !IsValid(observer_target) and IsValid(our_spect_target) then
			observer_target = our_spect_target
			if next_spect_target_change < CurTime() and our_spect_target:GetPos():Distance(client:GetPos()) > 100 then
				our_spect_target = nil
			end
		end
		if IsValid(observer_target) and observer_target.Nick then
			draw.Text({
				text = observer_target:Nick(),
				pos = {scrw / 2, scrh - (ud_panels_h / 2)},
				font = "cs_hud_spect_1",
				color = team.GetColor(observer_target:Team()),
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER
			})
		end
	--end
end)

print("Gamemode loaded cl_hud_spectator.lua")