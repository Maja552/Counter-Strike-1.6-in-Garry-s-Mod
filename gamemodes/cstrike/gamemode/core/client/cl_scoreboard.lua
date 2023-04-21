
local sb_mat_background = Material("cstrike_gm/sb_background.png")
local draw_bg_mat = true

UP_BEH_COUNT = 1
UP_BEH_CUSTOM = 2

function GM:ScoreboardShow()
	if IsValid(SB_Frame) then return end

	local client = LocalPlayer()
	local scrw = ScrW()
	local scrh = ScrH()
	--scrw = 1280 scrh = 720

	local size_mul = math.Clamp(scrh / 1080, 0.5, 1.2)
	local sm2 = 2 * size_mul
	local sm4 = 4 * size_mul
	local sm8 = 8 * size_mul
	local sm16 = 16 * size_mul
	local sm32 = 32 * size_mul
	local sm64 = 64 * size_mul

	if size_mul < 1 then
		draw_bg_mat = false
	end

	local font_info = {
		font = "Verdana",
		extended = false,
		size = 20 * size_mul,
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

	surface.CreateFont("cs_sb_1", font_info)
	--font_info.font = "VerdanaB"
	--surface.CreateFont("cs_sb_1b", font_info)

	local sb_frame_w = scrw / 2
	local sb_frame_h = scrh / 2
	local sb_frame_x = (scrw / 2) - (sb_frame_w / 2)
	local sb_frame_y = (scrh / 2) - (sb_frame_h / 2)

	SB_Frame = vgui.Create("DFrame")
	SB_Frame:Center()
	SB_Frame:SetPos(0, 0)
	SB_Frame:SetSize(scrw, scrh)
	SB_Frame:SetTitle("")
	SB_Frame:SetVisible(true)
	SB_Frame:SetDraggable(true)
	SB_Frame:SetDeleteOnClose(true)
	SB_Frame:SetDraggable(false)
	SB_Frame:ShowCloseButton(false)
	SB_Frame:Center()
	--SB_Frame:MakePopup()
	SB_Frame.Paint = function(self, w, h) end

	local img_bg = vgui.Create("DImage", SB_Frame)
	img_bg:SetSize(sb_bg_w * size_mul, sb_bg_h * size_mul)
	img_bg:Center()
	if draw_bg_mat then
		img_bg:SetMaterial(sb_mat_background)
	end

	
	local content = vgui.Create("DPanel", img_bg)
	content:SetSize(img_bg:GetSize())
	content:Center()
	if draw_bg_mat then
		content.Paint = function() end
	else
		content.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(15,15,15,125))
			surface.SetDrawColor(sb_color_main.r, sb_color_main.g, sb_color_main.b, 50)
			surface.DrawLine(0, 0, w, 0)
			surface.DrawLine(0, h - 1, w, h - 1)
			surface.DrawLine(0, 0, 0, h)
			surface.DrawLine(w - 1, 0, w - 1, h)
		end
	end
	
	local sb_up_panels = {
		ping = {
			name = "Latency",
			size  = 118 * size_mul,
			func = function(ply)
				if ply:IsBot() then
					return "BOT"
				end
				return ply:Ping()
			end,
			up_behaviour = UP_BEH_CUSTOM,
			up_func = function(team_id, player_list)
				local num = 0
				local avg_ping = 0
				for k,v in pairs(player.GetAll()) do
					if v:Team() == team_id and !v:IsBot() then
						avg_ping = avg_ping + v:Ping()
						num = num + 1
					end
				end
				if num == 0 then return "" end
				return "Avg : "..tostring(math.Round(avg_ping / num))
			end
		},
		deaths = {
			name = "Deaths",
			size  = 108 * size_mul,
			func = function(ply) return ply:Deaths() end,
			up_behaviour = UP_BEH_CUSTOM,
			up_func = function(team_id, player_list)
				local num = 0
				local avg_deaths = 0
				for k,v in pairs(player.GetAll()) do
					if v:Team() == team_id then
						avg_deaths = avg_deaths + v:Deaths()
						num = num + 1
					end
				end
				if num == 0 then return "" end
				return "Avg : "..tostring(math.Round(avg_deaths / num))
			end
		},
		frags = {
			name = "Score",
			size  = 90 * size_mul,
			func = function(ply) return ply:Frags() end,
			up_behaviour = UP_BEH_CUSTOM,
			up_func = function(team_id, player_list)
				return tostring(team.GetScore(team_id))
			end
		},
		money = {
			name = "Money",
			size  = 128 * size_mul,
			func = function(ply) return ply:GetMoney() end,
			text = function(ply, input) return "$"..tostring(input) end,
			up_behaviour = UP_BEH_COUNT
		},
		special = {
			name = "",
			size  = 92 * size_mul,
			update = false,
			func = function(ply)
				if ply:HasBomb() then
					return "Bomb"

				elseif ply:IsVIP() then
					return "VIP"
				end
				return ""
			end,
		},
		health = {
			name = "HP",
			size  = 160 * size_mul,
			func = function(ply) return ply:Health() end,
			text = function(ply, input)
				if !ply:Alive() or ply:IsSpectator() then
					return "Dead"
				end
				return tostring(ply:Health())
			end,
			up_behaviour = UP_BEH_CUSTOM,
			up_func = function(team_id, player_list)
				local num = 0
				local avg_health = 0
				for k,v in pairs(player.GetAll()) do
					if v:Team() == team_id and v:Alive() and !v:IsSpectator() then
						avg_health = avg_health + v:Health()
						num = num + 1
					end
				end
				if num == 0 then return "" end
				return "Avg : "..tostring(math.Round(avg_health / num))
			end
		},
	}

	if !SUBGAMEMODE.CONFIG.BUYING_ENABLED then
		sb_up_panels.money = nil
	end

	local last_x = 24 * size_mul

	for k,v in pairs(sb_up_panels) do
		v.pos = (sb_bg_w * size_mul) - last_x
		last_x = last_x + v.size
	end

	local content_up = vgui.Create("DPanel", content)
	content_up:SetPos(0, 0)
	content_up:SetSize(sb_bg_w * size_mul, sm32)
	content_up.Paint = function(self, w, h)
		--draw.RoundedBox(0, 0, 0, w, h, Color(255,255,255,5))
		draw.Text({
			text = GAMEMODE:GetHostName(),
			pos = {10 * size_mul, h / 2},
			font = "cs_sb_1",
			color = sb_color_main,
			xalign = TEXT_ALIGN_LEFT,
			yalign = TEXT_ALIGN_CENTER
		})

		for k,v in pairs(sb_up_panels) do
			local panel_x = v.pos
			--draw.RoundedBox(0, panel_x, 0, v[2], h, Color(255,255,255,50))
			draw.Text({
				text = v.name,
				pos = {panel_x, h / 2},
				font = "cs_sb_1",
				color = sb_color_main,
				xalign = TEXT_ALIGN_RIGHT,
				yalign = TEXT_ALIGN_CENTER
			})
		end
	end

	local content_height = (sb_bg_h * size_mul) - sm32

	local content_down = vgui.Create("DPanel", content)
	content_down:SetPos(0, sm32)
	content_down:SetSize(sb_bg_w * size_mul, content_height)
	content_down.Paint = function(self, w, h) end

	local sb_playerlists = table.Copy(SUBGAMEMODE.CONFIG.SB_PlayerLists)

	for i,v in ipairs(player.GetAll()) do
		local pl_team = v:Team()
		if v:Team() == TEAM_SPECTATOR then
			pl_team = v:CS16Team()
		end
		local team_tab = sb_playerlists[pl_team]
		if team_tab then
			table.ForceInsert(sb_playerlists[pl_team].tab, v)
		else
			table.ForceInsert(sb_playerlists[TEAM_SPECTATOR].tab, v)
		end
	end

	for k,v in pairs(sb_up_panels) do
		if v.up_behaviour == UP_BEH_COUNT then
			v.counted = {}
			for k2,v2 in pairs(sb_playerlists) do
				v.counted[k2] = 0
				for k3,v3 in pairs(v2.tab) do
					v.counted[k2] = v.counted[k2] + v.func(v3)
				end
			end
		end
	end

	local last_y = 0
	local last_y_calc = 0
	local player_panel_mul = 1

	for k,v in pairs(sb_playerlists) do
		last_y_calc = last_y_calc + (22 * size_mul)

		local pp_h = (48 * size_mul) * player_panel_mul
		for k2,v2 in pairs(v.tab) do
			last_y_calc = last_y_calc + pp_h + sm2
		end
	end

	if last_y_calc > content_height then
		player_panel_mul = (content_height * 0.91) / last_y_calc
	end

	local pp_h = (48 * size_mul) * player_panel_mul

	for k,v in pairs(sb_playerlists) do
		if #v.tab > 0 then
			local sb_panel_name = vgui.Create("DPanel", content_down)
			sb_panel_name:SetPos(0, last_y)
			sb_panel_name:SetSize(sb_bg_w * size_mul, 22 * size_mul)
			local use_s = ""
			if #v.tab > 1 then
				use_s = "s"
			end
			sb_panel_name.Think = function()
				for k2,v2 in pairs(sb_up_panels) do
					if v2.up_behaviour == UP_BEH_COUNT then
						v2.counted[k] = 0
						for k3,v3 in pairs(v.tab) do
							v2.counted[k] = v2.counted[k] + v2.func(v3)
						end
					end
				end
			end
			sb_panel_name.Paint = function(self, w, h)
				local tname = v.name
				if isfunction(tname) then tname = tname() end
				draw.Text({
					--text = v.name.."     -",  #v.tab.." player"..use_s,
					text = tname.." ("..#v.tab..")",
					pos = {52 * size_mul, h / 2},
					font = "cs_sb_1",
					color = v.clr,
					xalign = TEXT_ALIGN_LEFT,
					yalign = TEXT_ALIGN_CENTER
				})
				surface.SetDrawColor(v.clr.r, v.clr.g, v.clr.b, v.clr.a)
				surface.DrawLine(sm4, h - 1, w - sm4, h - 1)

				if v.show_infos then
					for k2,v2 in pairs(sb_up_panels) do
						if v2.up_behaviour then
							local dtext = ""
							if v2.up_behaviour == UP_BEH_COUNT then
								dtext = v2.counted[k]
								if v2.text then
									dtext = v2.text(nil, dtext)
								end

							elseif v2.up_behaviour == UP_BEH_CUSTOM then
								dtext = v2.up_func(k, v)
							end
							
							draw.Text({
								text = dtext,
								--pos = {v2.pos - 10 * size_mul, h / 2},
								pos = {v2.pos, h / 2},
								font = "cs_sb_1",
								color = v.clr,
								xalign = TEXT_ALIGN_RIGHT,
								yalign = TEXT_ALIGN_CENTER
							})
						end
					end
				end
			end
			last_y = last_y + (22 * size_mul)

			for k2,v2 in pairs(v.tab) do
				local sb_panel_player = vgui.Create("DPanel", content_down)
				sb_panel_player:SetPos(0, last_y)
				sb_panel_player:SetSize(sb_bg_w * size_mul, pp_h)
				sb_panel_player.texts = {}

				if v.show_infos then
					for k3,v3 in pairs(sb_up_panels) do
						if !v3.cond or v3.cond(v2) then
							local text = v3.func(v2)
							if v3.text then
								text = v3.text(v2, text)
							end
							text = {text, v3.update, k3, v3.pos}
							if text[2] == nil then text[2] = true end
							table.ForceInsert(sb_panel_player.texts, text)
						end
					end
				end

				local nextthink = 0
				sb_panel_player.Think = function(self)
					if !IsValid(v2) then sb_panel_player:Remove() return end
					if nextthink < CurTime() then
						for k4,v4 in pairs(self.texts) do
							if v4[2] == true then
								local sbup = sb_up_panels[v4[3]]
								if sbup then
									v4[1] = sbup.func(v2)
									if sbup.text then
										v4[1] = sbup.text(v2, v4[1])
									end
								end
							end
						end
						nextthink = CurTime() + 0.05
					end
				end
				sb_panel_player.nicktext = {
					text = v2:Nick(),
					pos = {56 * size_mul, pp_h / 2},
					font = "cs_sb_1",
					color = v.clr2 or v.clr,
					xalign = TEXT_ALIGN_LEFT,
					yalign = TEXT_ALIGN_CENTER
				}
				if v2:IsAdmin() then
					--sb_panel_player.nicktext.color = color_white
					sb_panel_player.nicktext.text = sb_panel_player.nicktext.text .. "	(Admin)"
				end
				sb_panel_player.Paint = function(self, w, h)
					if v2 == LocalPlayer() then
						draw.RoundedBox(0, 0, 0, w, h, Color(125,125,125,20))
					end

					draw.Text(self.nicktext)

					for k3,v3 in pairs(self.texts) do
						draw.Text({
							text = v3[1],
							pos = {v3[4], h / 2},
							font = "cs_sb_1",
							color = v.clr,
							xalign = TEXT_ALIGN_RIGHT,
							yalign = TEXT_ALIGN_CENTER
						})
					end
				end

				local sb_player_avatar = vgui.Create("AvatarImage", sb_panel_player)
				sb_player_avatar:SetSize(sm32 * player_panel_mul, sm32 * player_panel_mul)
				sb_player_avatar:SetPos(sm16, pp_h / 2 - (sm16 * player_panel_mul))
				sb_player_avatar:SetPlayer(v2, 32)

				last_y = last_y + pp_h + sm2
			end
		end
	end
end

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "HideScoreboardOnDisconnect", function(data)
	--GAMEMODE:ScoreboardHide()
end)

function GM:ScoreboardHide()
	if IsValid(SB_Frame) then
		SB_Frame:Remove()
	end
end

print("Gamemode loaded cl_scoreboard.lua")