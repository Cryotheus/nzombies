-- Chat Commands

nzChatCommand.Add("/activateelec", SERVER, function(ply, text) nzElec:Activate() end)

nzChatCommand.Add("/cheats", CLIENT, function(ply, text)
	if CLIENT then
		if not IsValid(g_nz_cheats) then g_nz_cheats = vgui.Create("NZCheatFrame")
		else g_nz_cheats:Remove() end
	else return true end -- Doesn't block the command (client does this instead)
end, false, "Opens the cheat panel.")

nzChatCommand.Add("/clean", SERVER, function(ply, text)
	if nzRound:InState(ROUND_CREATE) or nzRound:InState(ROUND_WAITING) then nzMapping:ClearConfig()
	else ply:PrintMessage(HUD_PRINTTALK, "[nZ] You can't clean a map config while playing. End the current round or go in creative mode and rerun the command.") end
end)

nzChatCommand.Add("/create", SERVER, function(ply, text)
	local target
	
	if text[1] then target = player.GetByName(text[1]) else target = ply end
	
	if IsValid(target) then target:ToggleCreativeMode()
	else ply:ChatPrint("[nZ] Could not find player '"..text[1].."', are you sure they exist?") end
end, false, "   Respawn in creative mode.")

nzChatCommand.Add("/dropin", SERVER, function(ply, text) ply:DropIn() end, true, "   Drop into the next round.")

nzChatCommand.Add("/dropout", SERVER, function(ply, text) ply:DropOut() end, true, "   Drop out of the current round.")

nzChatCommand.Add("/generate", SERVER, function(ply, text)
	if navmesh.IsLoaded() then ply:PrintMessage(HUD_PRINTTALK, "[nZ] Navmesh already exists, couldn't generate.")
	else
		ply:PrintMessage(HUD_PRINTTALK, "[nZ] Starting Navmesh Generation, this may take a while.")
		navmesh.BeginGeneration()
		
		if not navmesh.IsGenerating() then
			--force generation
			ply:PrintMessage(HUD_PRINTTALK, "[nZ] No walkable seeds found, this is a bad sign. Forcing generation...")
			
			--find the ground below a random spawn point, and force generation from there
			--could screw up if the spawn point is more than 100 units above ground or if the spawn is in the ground
			local ent = ents.Create("info_player_start")
			local spawn_point = GAMEMODE.SpawnPoints[math.random(#GAMEMODE.SpawnPoints)]
			local spawn_point_pos = spawn_point:GetPos()
			local trace = util.TraceLine({
				start = spawn_point_pos,
				endpos = spawn_point_pos - Vector(0, 0, 100),
				filter = spawn_point
			})
			
			ent:SetPos(trace.HitPos)
			ent:Spawn()
			navmesh.BeginGeneration()
		end
		
		if not navmesh.IsGenerating() then
			--Will not happen but just in case
			--no, it can happen
			ply:PrintMessage(HUD_PRINTTALK, "[nZ] Navmesh Generation failed. This is likely due to a spawn point being in the ground or too high off the ground.")
		end
	end
end, false, "   Generate a new naviagtion mesh.")

nzChatCommand.Add("/giveperk", SERVER, function(ply, text)
	local target = player.GetByName(text[1])
	local perk

	if not target then
		perk = text[1]
		target = ply
	else perk = text[2] end
	
	if IsValid(target) and target:Alive() and (target:IsPlaying() or nzRound:InState(ROUND_CREATE)) then
		if nzPerks:Get(perk) then target:GivePerk(perk)
		else ply:ChatPrint("[nZ] No valid perk provided.") end
	else ply:ChatPrint("[nZ] They player you have selected is either not valid or not alive.") end
end, false, "[playerName] perkID   Give a perk to yourself or another player.")

nzChatCommand.Add("/givepoints", SERVER, function(ply, text)
	local target = player.GetByName(text[1])
	local points
	
	if not target then
		points = tonumber(text[1])
		target = ply
	else points = tonumber(text[2]) end
	
	if IsValid(target) and target:Alive() and (target:IsPlaying() or nzRound:InState(ROUND_CREATE)) then
		if points then target:GivePoints(points)
		else ply:ChatPrint("[nZ] No valid number provided.") end
	else ply:ChatPrint("[nZ] The player you have selected is either not valid or not alive.") end
end, false, "[playerName] pointAmount   Give points to yourself or another player.")

nzChatCommand.Add("/giveweapon", SERVER, function(ply, text)
	local target = player.GetByName(text[1])
	local wep

	if not target then
		wep = weapons.Get(text[1])
		target = ply
	else wep = weapons.Get(text[2]) end
	
	if IsValid(target) and target:Alive() and (target:IsPlaying() or nzRound:InState(ROUND_CREATE)) then
		if wep then target:Give(wep.ClassName)
		else ply:ChatPrint("[nZ] No valid weapon provided.") end
	else ply:ChatPrint("[nZ] The player you have selected is either not valid or not alive.") end
end, false, "[playerName] weaponName   Give a weapon to yourself or another player.")

nzChatCommand.Add("/help", SERVER, function(ply, text)
	ply:PrintMessage(HUD_PRINTTALK, "-----")
	ply:PrintMessage(HUD_PRINTTALK, "[nZ] Available commands:")
	ply:PrintMessage(HUD_PRINTTALK, "Arguments in [] are optional.")
	
	for _, cmd in pairs(nzChatCommand.commands) do
		local cmdText = cmd[1]
		
		if cmd[4] then cmdText = cmdText .. " " .. cmd[4] end
		if cmd[3] or (not cmd[3] and ply:IsSuperAdmin()) then ply:PrintMessage(HUD_PRINTTALK, cmdText) end
	end
	
	ply:PrintMessage(HUD_PRINTTALK, "-----")
	ply:PrintMessage(HUD_PRINTTALK, "")
end, true, "   Print this list.")

nzChatCommand.Add("/load", SERVER, function(ply, text)
	--only allow loading a config when in creative or when in the waiting screen
	if nzRound:InState(ROUND_CREATE) or nzRound:InState(ROUND_WAITING) then nzInterfaces.SendInterface(ply, "ConfigLoader", nzMapping:GetConfigs())
	else ply:PrintMessage(HUD_PRINTTALK, "[nZ] You can't load a map config while playing. End the current round or go in creative mode and rerun the command.") end
end, false, "   Open the map config load dialog.")

nzChatCommand.Add("/maxammo", SERVER, function(ply, text)
	nzNotifications:PlaySound("nz/powerups/max_ammo.mp3", 2)
	
	for _, target in pairs(player.GetAll()) do target:GiveMaxAmmo() end
end, false, "Gives all players max ammo.")

nzChatCommand.Add("/navflush", SERVER, function(ply, text)
	nzNav.FlushAllNavModifications()
	PrintMessage(HUD_PRINTTALK, "[nZ] Navlocks successfully flushed. Remember to redo them for best playing experience.")
end)

nzChatCommand.Add("/ready", SERVER, function(ply, text) ply:ReadyUp() end, true, "   Mark yourself as ready.")

nzChatCommand.Add("/revive", SERVER, function(ply, text)
	local target = text[1] and player.GetByName(text[1]) or ply
	
	if IsValid(target) then
		if not target:GetNotDowned() then target:RevivePlayer()
		else ply:ChatPrint("[nZ] Player could not have been revived, they are not downed.") end
	else ply:ChatPrint("[nZ] Player could not have been revived, as no valid player was specified.") end
end, false, "[playerName]   Revive yourself or another player.")

nzChatCommand.Add("/save", SERVER, function(ply, text)
	if nzRound:InState(ROUND_CREATE) then
		--only save the map config if they are in creative mode
		net.Start("nz_SaveConfig")
		net.WriteString(nzMapping.CurrentConfig or "")
		net.Send(ply)
	else ply:PrintMessage(HUD_PRINTTALK, "[nZ] You can't save a config outside of creative mode.") end
end, false, "   Save your changes to a config.")

nzChatCommand.Add("/soundcheck", SERVER, function(ply, text)
	if ply:IsSuperAdmin() then
		nzNotifications:PlaySound("nz/powerups/double_points.mp3", 1)
		nzNotifications:PlaySound("nz/powerups/insta_kill.mp3", 2)
		nzNotifications:PlaySound("nz/powerups/max_ammo.mp3", 2)
		nzNotifications:PlaySound("nz/powerups/nuke.mp3", 2)
		
		nzNotifications:PlaySound("nz/round/round_start.mp3", 14)
		nzNotifications:PlaySound("nz/round/round_end.mp3", 9)
		nzNotifications:PlaySound("nz/round/game_over_4.mp3", 21)
	end
end, true)

nzChatCommand.Add("/spectate", SERVER, function(ply, text)
	--allow players to spectate ACTIVE rounds
	if not nzRound:InProgress() or nzRound:InState(ROUND_INIT) then ply:PrintMessage(HUD_PRINTTALK, "[nZ] No round in progress, could not set you to spectator.")
	elseif ply:IsReady() then
		ply:UnReady()
		ply:SetSpectator()
	else ply:SetSpectator() end
end, true)

nzChatCommand.Add("/targetpriority", SERVER, function(ply, text)
	local priority
	local strstart, strend = string.find(text[1], "entity(", 1, true)
	local target
	
	if strstart then
		--if they use the command with the parameter entity(#) where # is a number, target that entity
		--most of this code is just the parser and filter
		local _, strstop = string.find(text[1], ")", strend, true)
		local entity_index = string.sub(text[1], strend + 1, strstop - 1)
		
		if entity_index then
			local entity = Entity(entity_index)
			
			if IsValid(entity) then target = entity end
		end
	else target = player.GetByName(text[1]) end
	
	if not target then
		priority = tonumber(text[1])
		target = ply
	else priority = tonumber(text[2]) end
	
	if IsValid(target) and (not target:IsPlayer() or (target:Alive() and (target:IsPlaying() or nzRound:InState(ROUND_CREATE)))) then
		--because the line above is a bit stacked it breaks down to this:
		--if the target is valid, and it is a living and playing player, or a non player entity, then run this code
		if priority then target:SetTargetPriority(priority)
		else ply:ChatPrint("[nZ] No valid priority provided.") end
	else ply:ChatPrint("[nZ] The target you have selected is either not valid or the player is not alive.") end
end)

nzChatCommand.Add("/tools", SERVER, function(ply, text)
	if ply:IsInCreative() then
		ply:Give("weapon_physgun")
		ply:Give("nz_multi_tool")
	end
end, true, "Give creative mode tools to yourself if in Creative.")

nzChatCommand.Add("/unready", SERVER, function(ply, text) ply:UnReady() end, true, "   Mark yourself as unready.")