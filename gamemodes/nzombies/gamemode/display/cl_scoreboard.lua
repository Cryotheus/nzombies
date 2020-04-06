surface.CreateFont("ScoreboardDefault", {
	font	= "Helvetica",
	size	= 22,
	weight	= 800})

surface.CreateFont( "ScoreboardDefaultTitle", {
	font	= "Helvetica",
	size	= 32,
	weight	= 800})

local bloodline_scoreboard = Material("bloodline_scoreboard.png", "unlitgeneric smooth")

--This defines a new panel type for the player row. The player row is given a player
--and then from that point on it pretty much looks after itself. It updates player info
--in the think function, and removes itself when the player leaves the server.
local PLAYER_LINE = {
	Init = function(self)
		self.AvatarButton = self:Add("DButton")
		self.AvatarButton:Dock(LEFT)
		self.AvatarButton:SetSize(32, 32)
		self.AvatarButton.DoClick = function() self.Player:ShowProfile() end
		
		self.Avatar = vgui.Create("AvatarImage", self.AvatarButton)
		self.Avatar:SetSize(32, 32)
		self.Avatar:SetMouseInputEnabled(false)
		
		self.Name = self:Add("DLabel")
		self.Name:Dock(FILL)
		self.Name:SetFont("ScoreboardDefault")
		self.Name:SetTextColor(self.TextColor or color_white) --don't be afraid to use the color_white global!
		
		self.Mute = self:Add("DImageButton")
		self.Mute:SetSize(32, 32)
		self.Mute:Dock(RIGHT)
		
		self.Ping = self:Add("DLabel")
		self.Ping:Dock(RIGHT)
		self.Ping:SetWidth(50)
		self.Ping:SetFont("ScoreboardDefault")
		self.Ping:SetTextColor(color_white)
		self.Ping:SetContentAlignment(5)
		
		self.Revives = self:Add("DLabel")
		self.Revives:Dock(RIGHT)
		self.Revives:SetWidth(100)
		self.Revives:SetFont("ScoreboardDefault")
		self.Revives:SetTextColor(self.TextColor or color_white)
		self.Revives:SetContentAlignment(5)
		
		self.Downs = self:Add("DLabel")
		self.Downs:Dock(RIGHT)
		self.Downs:SetWidth(100)
		self.Downs:SetFont("ScoreboardDefault")
		self.Downs:SetTextColor(self.TextColor or color_white)
		self.Downs:SetContentAlignment(5)
		
		self.Kills = self:Add("DLabel")
		self.Kills:Dock(RIGHT)
		self.Kills:SetWidth( 100 )
		self.Kills:SetFont("ScoreboardDefault")
		self.Kills:SetTextColor(self.TextColor or color_white)
		self.Kills:SetContentAlignment(5)
		
		self.Points = self:Add("DLabel")
		self.Points:Dock(RIGHT)
		self.Points:SetWidth(100)
		self.Points:SetFont("ScoreboardDefault")
		self.Points:SetTextColor(self.TextColor or color_white)
		self.Points:SetContentAlignment(5)
		
		self.Items = self:Add("DPanel")
		self.Items:Dock(RIGHT)
		self.Items:SetWidth(175)
		self.Items.Paint = function(pnl)
			local num = 0
			
			surface.SetDrawColor(color_white)
			
			for _, v in pairs(self.Player:GetCarryItems()) do
				local item = nzItemCarry.Items[v]
				
				if item and (item.icon or item.model) then
					local x, y = pnl:GetPos()
					
					if item.model then
						surface.SetMaterial(item.model)
						surface.DrawTexturedRect(x - num * 26, y + 6, 24, 24)
						
						if item.icon then
							surface.SetMaterial(item.icon)
							surface.DrawTexturedRect(x - num * 26 + 18, y, 12, 12)
						end
					else
						surface.SetMaterial(item.icon)
						surface.DrawTexturedRect(x - num * 26, y + 6, 24, 24)
					end
					
					num = num + 1
				end
			end
		end
		
		self:Dock(TOP)
		self:SetSize(32, 32)
		self:DockMargin(5, 0, 5, 0)
	end,
	Setup = function(self, pl)
		self.Player = pl
		self.Avatar:SetPlayer(pl)
		
		self:Think(self)
	end,
	Think = function(self)
		if not IsValid(self.Player) then
			self:SetZPos(9999) --causes a rebuild
			self:Remove()
			
			return
		end
		
		if not self.TextColor or self.TextColor ~= player.GetColorByIndex(self.Player:EntIndex()) then
			self.TextColor = player.GetColorByIndex(self.Player:EntIndex())
			
			self.Downs:SetTextColor(self.TextColor)
			self.Kills:SetTextColor(self.TextColor)
			self.Name:SetTextColor(self.TextColor)
			self.Ping:SetTextColor(self.TextColor)
			self.Points:SetTextColor(self.TextColor)
			self.Revives:SetTextColor(self.TextColor)
		end
		
		if not self.ZombieKills or self.ZombieKills ~= self.Player:GetTotalKills() then
			self.ZombieKills = self.Player:GetTotalKills()
			
			self.Kills:SetText(self.ZombieKills)
		end
		
		if not self.NumDowns or self.Downs ~= self.Player:GetTotalDowns() then
			self.NumDowns = self.Player:GetTotalDowns()
			
			self.Downs:SetText(self.NumDowns)
		end
		
		if not self.NumRevives or self.NumRevives ~= self.Player:GetTotalRevives() then
			self.NumRevives = self.Player:GetTotalRevives()
			
			self.Revives:SetText(self.NumRevives)
		end
		
		if not self.PName or self.PName ~= self.Player:Nick() then
			self.PName = self.Player:Nick()
			
			self.Name:SetText(self.PName)
		end
		
		if not self.NumPoints or self.NumPoints ~= self.Player:GetPoints() then
			self.NumPoints = self.Player:GetPoints()
			
			self.Points:SetText(self.NumPoints)
		end
		
		if not self.NumPing or self.NumPing ~= self.Player:Ping() then
			self.NumPing = self.Player:Ping()
			
			self.Ping:SetText(self.NumPing)
		end
		
		--change the icon of the mute button based on state
		if not self.Muted or self.Muted ~= self.Player:IsMuted() then
			self.Muted = self.Player:IsMuted()
			
			if self.Muted then self.Mute:SetImage("icon32/muted.png")
			else self.Mute:SetImage("icon32/unmuted.png") end
			
			self.Mute.DoClick = function() self.Player:SetMuted(not self.Muted) end
		end
		
		--connecting players go at the very bottom
		if self.Player:Team() == TEAM_CONNECTING then
			self:SetZPos(2000 + self.Player:EntIndex())
			
			return
		end
		
		--This is what sorts the list. The panels are docked in the z order,
		--so if we set the z order according to kills they'll be ordered that way!
		--Careful though, it's a signed short internally, so needs to range between -32,768k and +32,767
		self:SetZPos(self.Player:EntIndex() - self.NumPoints)
	end,
	Paint = function(self, w, h)
		if not IsValid(self.Player) then return end
		
		if self.Player:Alive() then surface.SetDrawColor(200, 200, 200)
		else surface.SetDrawColor(120, 120, 120) end
		
		surface.SetMaterial(player.GetBloodByIndex(self.Player:EntIndex()))
		surface.DrawTexturedRect(0, 0, w, h)
	end
}

--convert it from a normal table into a Panel Table based on DPanel
PLAYER_LINE = vgui.RegisterTable(PLAYER_LINE, "DPanel")

--here we define a new panel table for the scoreboard. It basically consists
--of a header and a scrollpanel - into which the player lines are placed.
local SCORE_BOARD = {
	Init = function(self)
		self.Header = self:Add("Panel")
		self.Header:Dock(TOP)
		self.Header:SetHeight(100)
		
		self.Name = self.Header:Add("DLabel")
		self.Name:SetFont("nz.display.hud.main")
		self.Name:SetTextColor(color_white)
		self.Name:Dock(TOP)
		self.Name:SetHeight(40)
		self.Name:SetContentAlignment(5)
		
		self.Key = self:Add("DPanel")
		self.Key:Dock(TOP)
		self.Key:SetContentAlignment(6)
		self.Key:SetHeight(20)
		self.Key.Paint = function() end
		
		self.Mute = self.Key:Add("DLabel")
		self.Mute:Dock(RIGHT)
		self.Mute:SetWidth(32)
		self.Mute:SetFont("ScoreboardDefault")
		self.Mute:SetTextColor(color_white)
		self.Mute:SetContentAlignment(5)
		self.Mute:SetText("")
		
		self.Ping = self.Key:Add("DLabel")
		self.Ping:Dock(RIGHT)
		self.Ping:SetWidth(50)
		self.Ping:SetFont("ScoreboardDefault")
		self.Ping:SetTextColor(color_white)
		self.Ping:SetContentAlignment(5)
		self.Ping:SetText("Ping")
		
		self.Revives = self.Key:Add("DLabel")
		self.Revives:Dock(RIGHT)
		self.Revives:SetWidth(100)
		self.Revives:SetFont("ScoreboardDefault")
		self.Revives:SetTextColor(color_white)
		self.Revives:SetContentAlignment( 5 )
		self.Revives:SetText("Revives")
		
		self.Downs = self.Key:Add("DLabel")
		self.Downs:Dock(RIGHT)
		self.Downs:SetWidth(100)
		self.Downs:SetFont("ScoreboardDefault")
		self.Downs:SetTextColor(color_white)
		self.Downs:SetContentAlignment(5)
		self.Downs:SetText("Downs")
		
		self.Kills = self.Key:Add("DLabel")
		self.Kills:Dock(RIGHT)
		self.Kills:SetWidth(100)
		self.Kills:SetFont("ScoreboardDefault")
		self.Kills:SetTextColor(color_white)
		self.Kills:SetContentAlignment(5)
		self.Kills:SetText("Kills")
		
		self.Points = self.Key:Add("DLabel")
		self.Points:Dock(RIGHT)
		self.Points:SetWidth(100)
		self.Points:SetFont("ScoreboardDefault")
		self.Points:SetTextColor(color_white)
		self.Points:SetContentAlignment(5)
		self.Points:SetText("Points")
		
		--self.NumPlayers = self.Header:Add("DLabel")
		--self.NumPlayers:SetFont("ScoreboardDefault")
		--self.NumPlayers:SetTextColor(color_white)
		--self.NumPlayers:SetPos(0, 70) --100 subtracted by the height
		--self.NumPlayers:SetSize(300, 30)
		--self.NumPlayers:SetContentAlignment(4)
		
		self.Scores = self:Add("DScrollPanel")
		self.Scores:Dock(FILL)
	end,
	PerformLayout = function(self)
		self:SetSize(800, ScrH() - 200)
		self:SetPos(ScrW() * 0.5 - 400, 100)
	end,
	Paint = function(self, w, h) --DrawBlurRect(0, 0, w, h) end,
	Think = function(self, w, h)
		self.Name:SetText(GetHostName()) --probably a less expensive way to do this
		
		--loop through each player, and if one doesn't have a score entry - create it.
		for id, pl in pairs(player.GetAll()) do
			if IsValid(pl.ScoreEntry) then continue end
			
			pl.ScoreEntry = vgui.CreateFromTable(PLAYER_LINE, pl.ScoreEntry)
			pl.ScoreEntry:Setup(pl)
			
			self.Scores:AddItem(pl.ScoreEntry)
		end
	end
}

SCORE_BOARD = vgui.RegisterTable( SCORE_BOARD, "EditablePanel" )

function GM:ScoreboardShow()
	if not IsValid(g_Scoreboard) then g_Scoreboard = vgui.CreateFromTable(SCORE_BOARD) end

	if IsValid(g_Scoreboard) then
		g_Scoreboard:Show()
		g_Scoreboard:MakePopup()
		g_Scoreboard:SetKeyboardInputEnabled(false)
	end
end

function GM:ScoreboardHide() if IsValid( g_Scoreboard) then g_Scoreboard:Hide() end end

function GM:HUDDrawScoreBoard() end