
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

surface.CreateFont("cs_trid_1", font_info)

function GM:HUDDrawTargetID()
	local client = LocalPlayer()
	local is_spec = client:IsSpectator()

	local tr = client:GetEyeTrace()
	if !tr.Hit then return end
	if !tr.HitNonWorld then return end
	
	local ent = tr.Entity
	
	local is_ragdoll = ent:GetClass() == "prop_ragdoll"
	local is_valid_ply = ent:IsPlayer() and !ent:IsSpectator() and ent:Team() != TEAM_UNASSIGNED and ent:Alive()
	local is_barricade = ent:GetClass() == "zm_barricade"

	if IsValid(ent) then
		local text = ""
		local clr = Color(0,0,0,0)
		if is_barricade then
			text = "Barricade Health: "..ent:Health()
			clr = cs16_main_color
		elseif is_ragdoll then
			local text1 = "Friend"
			local team_id = ent:GetNWInt("RagdollTeam", nil)
			local nick = ent:GetNWString("RagdollNick", nil)
			if !team_id or !nick then return end
			if client:IsCS16EnemyTeam(team_id) then
				text1 = "Enemy"
			end
			--if is_spec then
			--	text1 = "Player"
			--end
			text = "Dead "..text1.." : "..nick
			clr = team.GetColor(team_id)

		elseif is_valid_ply then
			local text1 = "Friend"
			if client:IsCS16Enemy(ent) then
				text1 = "Enemy"
			end
			--if is_spec then
			--	text1 = "Player"
			--end
			text = text1.." : "..ent:Nick().."  Health : "..ent:Health().."%"
			clr = self:GetTeamColor(ent)
		end
		draw.Text({
			text = text,
			pos = {16, ScrH() - 48},
			font = "cs_trid_1",
			color = clr,
			xalign = TEXT_ALIGN_LEFT,
			yalign = TEXT_ALIGN_BOTTOM
		})
	end
end

print("Gamemode loaded cl_targetid.lua")