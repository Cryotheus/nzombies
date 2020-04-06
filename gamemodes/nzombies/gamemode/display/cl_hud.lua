nzDisplay = nzDisplay or AddNZModule("Display")

local blockedweps = {
	["nz_revive_morphine"] = true,
	["nz_packapunch_arms"] = true,
	["nz_perk_bottle"] = true}
local bloodline_points = Material("bloodline_score2.png", "unlitgeneric smooth")
local bloodline_gun = Material("cod_hud.png", "unlitgeneric smooth")
local grenade_icon = Material("grenade-256.png", "unlitgeneric smooth")
local infmat = Material("materials/round_-1.png", "smooth")
local laser = Material("cable/redlaser")
local points_notifications = {}
local prev_round_special = false
local round_change_ending = false
local round_alpha = 255
local round_num = 0
local round_white = 0
local vulture_textures = {
	["wall_buys"] = Material("vulture_icons/wall_buys.png", "smooth unlitgeneric"),
	["random_box"] = Material("vulture_icons/random_box.png", "smooth unlitgeneric"),
	["wunderfizz_machine"] = Material("vulture_icons/wunderfizz.png", "smooth unlitgeneric")}

local fl_draw_SimpleText = draw.SimpleText
local fl_draw_SimpleTextOutlined = draw.SimpleTextOutlined
local fl_surface_GetTextSize = draw.SimpleText
local fl_surface_SetDrawColor = surface.SetDrawColor
local fl_surface_SetFont = surface.SetFont
local fl_surface_SetMaterial = surface.SetMaterial
local fl_surface_DrawTexturedRect = surface.DrawTexturedRect
local fl_table_insert = table.insert

local point_notif_font = "nz.display.hud.points"
local round_hud_font = "nz.display.hud.rounds"
local score_hud_font = "nz.display.hud.small"

CreateClientConVar("nz_hud_points_show_names", "1", true, false)

local function StatesHud()
	if GetConVar("cl_drawhud"):GetBool() then
		local text = ""
		local font = "nz.display.hud.main"
		local w = ScrW() / 2
		
		if nzRound:InState(ROUND_WAITING) then
			text = "Waiting for players. Type /ready to ready up."
			font = "nz.display.hud.small"
		elseif nzRound:InState(ROUND_CREATE) then text = "Creative Mode"
		elseif nzRound:InState(ROUND_GO) then text = "Game Over" end
		
		fl_draw_SimpleText(text, font, w, ScrH() * 0.85, Color(200, 0, 0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

local function ScoreHud()
	if GetConVar("cl_drawhud"):GetBool() then
		if nzRound:InProgress() then
			local scale = (ScrW() / 1920 + 1) / 2
			local offset = 0
			
			for k, ply in pairs(player.GetAll()) do
				local hp = ply:Health()
				
				if hp == 0 then hp = "Dead" elseif nzRevive.Players[ply:EntIndex()] then hp = "Downed" else hp = hp .. " HP"  end
				
				if ply:GetPoints() >= 0 then
					local text = ""
					local nameoffset = 0
					
					if GetConVar("nz_hud_points_show_names"):GetBool() then
						local nick = string.sub(ply:Nick() , 1, math.Min(string.len(ply:Nick()), 20))
						
						text = nick
						nameoffset = 10
					end
					
					local font = score_hud_font
					
					fl_surface_SetFont(font)
					
					local textW, textH = surface.GetTextSize(text)
					
					if LocalPlayer() == ply then offset = offset + textH + 5 -- change this if you change the size of nz.display.hud.medium
					else offset = offset + textH end
					
					fl_surface_SetDrawColor(200, 200, 200)
					
					local index = ply:EntIndex()
					local color = player.GetColorByIndex(ply:EntIndex())
					local blood = player.GetBloodByIndex(ply:EntIndex())
					
					fl_surface_SetMaterial(blood)
					fl_surface_DrawTexturedRect(ScrW() - textW - 180, ScrH() - 275 * scale - offset, textW + 150, 45)
					
					if text then fl_draw_SimpleText(text, font, ScrW() - textW - 60, ScrH() - 255 * scale - offset, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
					if LocalPlayer() == ply then font = "nz.display.hud.medium" end
					
					fl_draw_SimpleText(ply:GetPoints(), font, ScrW() - textW - 60 - nameoffset, ScrH() - 255 * scale - offset, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					
					ply.PointsSpawnPosition = {x = ScrW() - textW - 170, y = ScrH() - 255 * scale - offset}
				end
			end
		end
	end
end

local function GunHud()
	if GetConVar("cl_drawhud"):GetBool() then
		if not LocalPlayer():IsNZMenuOpen() then
			local wep = LocalPlayer():GetActiveWeapon()
			local w, h = ScrW(), ScrH()
			local scale = (w / 1920 + 1) * 0.5
			
			fl_surface_SetMaterial(bloodline_gun)
			fl_surface_SetDrawColor(200, 200, 200)
			fl_surface_DrawTexturedRect(w - 630 * scale, h - 225 * scale, 600 * scale, 225 * scale)
			
			if IsValid(wep) then
				if wep:GetClass() == "nz_multi_tool" then
					fl_draw_SimpleTextOutlined(nzTools.ToolData[wep.ToolMode].displayname or wep.ToolMode, "nz.display.hud.small", w - 240 * scale, h - 125 * scale, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
					fl_draw_SimpleTextOutlined(nzTools.ToolData[wep.ToolMode].desc or "", "nz.display.hud.smaller", w - 240 * scale, h - 90 * scale, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, color_black)
				else
					local name = wep:GetPrintName()					
					local x = 250
					local y = 165
					
					if wep:GetPrimaryAmmoType() ~= -1 then
						local clip
						
						if wep.Primary.ClipSize and wep.Primary.ClipSize ~= -1 then
							fl_draw_SimpleTextOutlined("/" .. wep:Ammo1(), "nz.display.hud.ammo2", ScrW() - 310 * scale, ScrH() - 120 * scale, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, color_black)
							
							clip = wep:Clip1()
							x = 315
							y = 155
						else clip = wep:Ammo1() end
						
						fl_draw_SimpleTextOutlined(clip, "nz.display.hud.ammo", ScrW() - x * scale, ScrH() - 115 * scale, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
						
						x = x + 80
					end
					
					fl_draw_SimpleTextOutlined(name, "nz.display.hud.small", ScrW() - x * scale, ScrH() - 120 * scale, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
					
					x = 270
					
					if wep:GetSecondaryAmmoType() ~= -1 then
						local clip
						
						if wep.Secondary.ClipSize and wep.Secondary.ClipSize ~= -1 then
							fl_draw_SimpleTextOutlined("/" .. wep:Ammo2(), "nz.display.hud.ammo4", ScrW() - x * scale, ScrH() - y * scale, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, color_black)
							
							clip = wep:Clip2()
							x = x + 3
						else clip = wep:Ammo2() end
						
						fl_draw_SimpleTextOutlined(clip, "nz.display.hud.ammo3", ScrW() - x * scale, ScrH() - y * scale, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
						
						x = x + 80
					end
				end
			end
		end
	end
end

local function PowerUpsHud()
	if nzRound:InProgress() or nzRound:InState(ROUND_CREATE) then
		local font = "nz.display.hud.main"
		local w = ScrW() / 2
		local offset = 40
		local c = 0
		local time = CurTime()
		
		for index, power_up in pairs(nzPowerUps.ActivePowerUps) do
			if nzPowerUps:IsPowerupActive(index) then
				local powerupData = nzPowerUps:Get(index)
				
				fl_draw_SimpleText(powerupData.name .. " - " .. math.Round(power_up - time), font, w, ScrH() * 0.85 + offset * c, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				
				c = c + 1
			end
		end
		
		if not nzPowerUps.ActivePlayerPowerUps[LocalPlayer()] then nzPowerUps.ActivePlayerPowerUps[LocalPlayer()] = {} end
		
		--this could be a better version, if nzPowerUps.ActivePlayerPowerUps[LocalPlayer()] is not used down the line
		--for index, power_up in pairs(nzPowerUps.ActivePlayerPowerUps[LocalPlayer()] or {}) do
		for index, power_up in pairs(nzPowerUps.ActivePlayerPowerUps[LocalPlayer()]) do
			if nzPowerUps:IsPlayerPowerupActive(LocalPlayer(), index) then
				local powerupData = nzPowerUps:Get(index)
				
				fl_draw_SimpleText(powerupData.name .. " - " .. math.Round(power_up - time), font, w, ScrH() * 0.85 + offset * c, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				
				c = c + 1
			end
		end
	end
end

function nzDisplay.DrawLinks(source_entity, link)
	local tbl = {}
	
	for entity_index, entity in pairs(ents.GetAll()) do
		if entity:IsBuyableProp() then if nzDoors.PropDoors[entity_index] and entity.link == link then fl_table_insert(tbl, Entity(entity_index)) end
		elseif entity:IsDoor() then if nzDoors.MapDoors[entity:doorIndex()] and nzDoors.MapDoors[entity:doorIndex()].link == link then fl_table_insert(tbl, v) end
		elseif entity:GetClass() == "nz_spawn_zombie_normal" and entity:GetLink() == link then fl_table_insert(tbl, entity) end
	end
	
	if tbl[1] then
		for entity_index, entity in pairs(tbl) do
			render.SetMaterial(laser)
			render.DrawBeam(source_entity:GetPos(), entity:GetPos(), 20, 1, 1, Color(255, 255, 255, 255))
		end
	end
end

local function PointsNotification(ply, amount)
	if not IsValid(ply) then return end
	local data = {ply = ply, amount = amount, diry = math.random(-20, 20), time = CurTime()}
	
	fl_table_insert(points_notifications, data)
end

net.Receive("nz_points_notification", function()
	local amount = net.ReadInt(20)
	local ply = net.ReadEntity()

	PointsNotification(ply, amount)
end)

local function DrawPointsNotification()
	if GetConVar("nz_point_notification_clientside"):GetBool() then
		for _, ply in pairs(player.GetAll()) do
			if ply:GetPoints() >= 0 then
				ply.LastPoints = ply.LastPoints or 0
				
				if ply:GetPoints() ~= ply.LastPoints then
					PointsNotification(ply, ply:GetPoints() - ply.LastPoints)
					
					ply.LastPoints = ply:GetPoints()
				end
			end
		end
	end
	
	for index, notif in pairs(points_notifications) do
		local fade = math.Clamp(CurTime() - notif.time, 0, 1)
		
		if not notif.ply.PointsSpawnPosition then return end
		
		if notif.amount >= 0 then fl_draw_SimpleText(notif.amount, point_notif_font, notif.ply.PointsSpawnPosition.x - 50 * fade, notif.ply.PointsSpawnPosition.y + notif.diry * fade, Color(255, 255, 0, 255 - 255 * fade), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		else fl_draw_SimpleText(notif.amount, point_notif_font, notif.ply.PointsSpawnPosition.x - 50 * fade, notif.ply.PointsSpawnPosition.y + notif.diry * fade, Color(255, 0, 0, 255 - 255 * fade), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER) end
		
		if fade >= 1 then table.remove(points_notifications, index) end
	end
end

local function PerksHud()
	local scale = (ScrW()/1920 + 1)/2
	local w = -20
	local size = 50
	
	for k, v in pairs(LocalPlayer():GetPerks()) do
		fl_surface_SetMaterial(nzPerks:Get(v).icon)
		fl_surface_SetDrawColor(255,255,255)
		fl_surface_DrawTexturedRect(w + k * (size * scale + 10), ScrH() - 200, size * scale, size * scale)
	end
end

local function VultureVision()
	if not LocalPlayer():HasPerk("vulture") then return end
	local scale = (ScrW() / 1920 + 1) / 2

	for _, ent in pairs(ents.FindInSphere(LocalPlayer():GetPos(), 700)) do
		local target = ent:GetClass()
		
		if vulture_textures[target] then
			local data = ent:WorldSpaceCenter():ToScreen()
			
			if data.visible then
				fl_surface_SetMaterial(vulture_textures[target])
				fl_surface_SetDrawColor(255, 255, 255, 150)
				fl_surface_DrawTexturedRect(data.x - 15 * scale, data.y - 15 * scale, 30 * scale, 30 * scale)
			end
		elseif target == "perk_machine" then
			local data = ent:WorldSpaceCenter():ToScreen()
			
			if data.visible then
				local icon = nzPerks:Get(ent:GetPerkID()).icon
				
				if icon then
					fl_surface_SetMaterial(icon)
					fl_surface_SetDrawColor(255, 255, 255, 150)
					fl_surface_DrawTexturedRect(data.x - 15 * scale, data.y - 15 * scale, 30 * scale, 30 * scale)
				end
			end
		end
	end
end

local function RoundHud()
	local text = ""
	local w = 70
	local h = ScrH() - 30
	local col = Color(200 + round_white * 55, round_white, round_white, round_alpha)
	
	if round_num == -1 then
		fl_surface_SetMaterial(infmat)
		fl_surface_SetDrawColor(col.r,round_white,round_white,round_alpha)
		fl_surface_DrawTexturedRect(w - 25, h - 100, 200, 100)
		
		return
	elseif round_num < 11 then
		for i = 1, round_num do
			if i == 5 or i == 10 then text = text .. " "
			else text = text .. "i" end
		end
		
		if round_num >= 5 then draw.TextRotatedScaled("i", w + 200, h - 295, col, round_hud_font, 60, 1, 1.7) end
		if round_num >= 10 then draw.TextRotatedScaled("i", w + 420, h - 295, col, round_hud_font, 60, 1, 1.7) end
	else text = round_num end
	
	fl_draw_SimpleText(text, round_hud_font, w, h, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end

local function StartChangeRound()
	local lastround = nzRound:GetNumber()
	
	if lastround >= 1 then
		if prev_round_special then surface.PlaySound("nz/round/special_round_end.wav")
		else surface.PlaySound("nz/round/round_end.mp3") end
	elseif lastround == -2 then surface.PlaySound("nz/round/round_-1_prepare.mp3")
	else round_num = 0 end
	
	round_change_ending = false
	round_white = 0
	
	local round_charger = 0.25
	local alphafading = false
	local haschanged = false
	
	hook.Add("HUDPaint", "nz_roundnumWhiteFade", function()
		if not alphafading then
			round_white = math.Approach(round_white, round_charger > 0 and 255 or 0, round_charger * 350 * FrameTime())
			
			if round_white >= 255 and not round_change_ending then
				alphafading = true
				round_charger = -1
			elseif round_white <= 0 and round_change_ending then hook.Remove("HUDPaint", "nz_roundnumWhiteFade") end
		else
			round_alpha = math.Approach(round_alpha, round_charger > 0 and 255 or 0, round_charger * 350 * FrameTime())
			
			if round_alpha >= 255 then
				if haschanged then
					alphafading = false
					round_charger = -0.25
				else round_charger = -1 end
			elseif round_alpha <= 0 then
				if round_change_ending then
					round_charger = 0.5
					round_num = nzRound:GetNumber()
					
					if round_num == -1 then --surface.PlaySound("nz/easteregg/motd_round-03.wav")
					elseif nzRound:IsSpecial() then
						surface.PlaySound("nz/round/special_round_start.wav")
						
						prev_round_special = true
					else
						surface.PlaySound("nz/round/round_start.mp3")
						
						prev_round_special = false
					end
					
					haschanged = true
				else round_charger = 1 end
			end
		end
	end)
end

local function EndChangeRound() round_change_ending = true end

local function DrawGrenadeHud()
	local num = LocalPlayer():GetAmmoCount(GetNZAmmoID("grenade") or -1)
	local numspecial = LocalPlayer():GetAmmoCount(GetNZAmmoID("specialgrenade") or -1)
	local scale = (ScrW() / 1920 + 1) / 2
	
	if num > 0 then
		fl_surface_SetMaterial(grenade_icon)
		fl_surface_SetDrawColor(255, 255, 255)
		
		for i = num, 1, -1 do fl_surface_DrawTexturedRect(ScrW() - 250 * scale - i * 10 * scale, ScrH() - 90 * scale, 30 * scale, 30 * scale) end
	end
	
	if numspecial > 0 then
		fl_surface_SetMaterial(grenade_icon)
		fl_surface_SetDrawColor(255, 100, 100)
		
		for i = numspecial, 1, -1 do fl_surface_DrawTexturedRect(ScrW() - 300 * scale - i * 10 * scale, ScrH() - 90 * scale, 30 * scale, 30 * scale) end
	end
end

-- Hooks
hook.Add("HUDPaint", "pointsNotifcationHUD", DrawPointsNotification)
hook.Add("HUDPaint", "roundHUD", StatesHud)
hook.Add("HUDPaint", "scoreHUD", ScoreHud)
hook.Add("HUDPaint", "gunHUD", GunHud)
hook.Add("HUDPaint", "powerupHUD", PowerUpsHud)
hook.Add("HUDPaint", "perksHUD", PerksHud)
hook.Add("HUDPaint", "vultureVision", VultureVision)
hook.Add("HUDPaint", "roundnumHUD", RoundHud)
hook.Add("HUDPaint", "grenadeHUD", DrawGrenadeHud)

hook.Add("OnRoundPreparation", "BeginRoundHUDChange", StartChangeRound)
hook.Add("OnRoundStart", "EndRoundHUDChange", EndChangeRound)

function GM:HUDWeaponPickedUp(wep)
	if not IsValid(LocalPlayer()) or not LocalPlayer():Alive() or not IsValid(wep) or not isfunction(wep.GetPrintName) or blockedweps[wep:GetClass()] then return end
	
	local pickup = {}
	
	pickup.color = Color(255, 200, 50, 255)
	pickup.fadein = 0.04
	pickup.fadeout = 0.3
	pickup.font = "DermaDefaultBold"
	pickup.holdtime = 5
	pickup.name = wep:GetPrintName()
	pickup.time = CurTime()
	
	fl_surface_SetFont(pickup.font)
	
	pickup.width, pickup.height = fl_draw_SimpleText(pickup.name) --we can do this?
	
	if self.PickupHistoryLast >= pickup.time then pickup.time = self.PickupHistoryLast + 0.05 end

	fl_table_insert(self.PickupHistory, pickup)
	
	self.PickupHistoryLast = pickup.time
	
	if wep.NearWallEnabled then wep.NearWallEnabled = false end
	if wep:IsFAS2() then wep.NoNearWall = true end
end

local function ParseAmmoName(str)
	local pattern = "nz_weapon_ammo_(%d)"
	local slot = tonumber(string.match(str, pattern))
	
	if slot then
		for _, v in pairs(LocalPlayer():GetWeapons()) do
			if v:GetNWInt("SwitchSlot", -1) == slot then
				if v.Primary and v.Primary.OldAmmo then return "#" .. v.Primary.OldAmmo .. "_ammo" end
				
				local wep = weapons.Get(v:GetClass())
				
				if wep and wep.Primary and wep.Primary.Ammo then return "#" .. wep.Primary.Ammo .. "_ammo" end
				
				return v:GetPrintName() .. " Ammo"
			end
		end
	end
	
	return str
end

function GM:HUDAmmoPickedUp(itemname, amount)
	if not IsValid(LocalPlayer()) or not LocalPlayer():Alive() then return end
	
	itemname = ParseAmmoName(itemname)
	
	if self.PickupHistory then
		for k, v in pairs(self.PickupHistory) do
			if v.name == itemname then
				v.amount = tostring(tonumber(v.amount) + amount)
				v.time = CurTime() - v.fadein
				
				return
			end
		end
	end
	
	local pickup = {}
	pickup.time = CurTime()
	pickup.name = itemname
	pickup.holdtime = 5
	pickup.font = "DermaDefaultBold"
	pickup.fadein = 0.04
	pickup.fadeout = 0.3
	pickup.color = Color(180, 200, 255, 255)
	pickup.amount = tostring(amount)
	
	fl_surface_SetFont(pickup.font)
	
	pickup.width, pickup.height = fl_draw_SimpleText(pickup.name)
	pickup.xwidth = fl_draw_SimpleText(pickup.amount)
	pickup.width = pickup.width + pickup.xwidth + 16

	if self.PickupHistoryLast >= pickup.time then pickup.time = self.PickupHistoryLast + 0.05 end
	
	fl_table_insert(self.PickupHistory, pickup)
	
	self.PickupHistoryLast = pickup.time
end