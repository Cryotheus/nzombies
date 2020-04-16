local revivefailtime = 0.2

function nzRevive.HandleRevive(ply, ent)
	if not nzRevive.Players[ply:EntIndex()] then
		local cur_time = CurTime()
		local trace = util.QuickTrace(ply:EyePos(), ply:GetAimVector() * 100, ply)
		local downed_ply = trace.Entity
		
		if IsValid(downed_ply) and (downed_ply:IsPlayer() or downed_ply:GetClass() == "whoswho_downed_clone") then
			local id = downed_ply:EntIndex()
			
			if nzRevive.Players[id] then
				if not nzRevive.Players[id].RevivePlayer then downed_ply:StartRevive(ply) end
				
				if ply:HasPerk("revive") and cur_time - nzRevive.Players[id].ReviveTime >= 2 or cur_time - nzRevive.Players[id].ReviveTime >= 4 then
					--it takes 2 seconds to revive with quick revive and 4 normally
					downed_ply:RevivePlayer(ply)
					
					ply.Reviving = nil
				end
			end
		elseif ply.LastReviveTime and IsValid(ply.Reviving) and ply.Reviving ~= downed_ply and cur_time > ply.LastReviveTime + revivefailtime then
			local id = ply.Reviving:EntIndex()
			
			if nzRevive.Players[id] and nzRevive.Players[id].ReviveTime then
				ply.Reviving:StopRevive()
				
				ply.Reviving = nil
			end
		end
		
		--when a player stops reviving
		if not ply:KeyDown(IN_USE) then --if you have an old revival target
			if IsValid(ply.Reviving) and (ply.Reviving:IsPlayer() or ply.Reviving:GetClass() == "whoswho_downed_clone") then
				local id = ply.Reviving:EntIndex()
				
				if nzRevive.Players[id] then
					if nzRevive.Players[id].ReviveTime then
						ply.Reviving:StopRevive()
						ply.Reviving = nil
					end
				end
			end
		end
	end
end

-- Hooks
hook.Add("FindUseEntity", "CheckRevive", nzRevive.HandleRevive)

if SERVER then
	util.AddNetworkString("nz_TombstoneSuicide")
	util.AddNetworkString("nz_WhosWhoActive")
	
	net.Receive("nz_TombstoneSuicide", function(len, ply)
		if ply:GetDownedWithTombstone() then
			local tombstone = ents.Create("drop_tombstone")
			
			tombstone:SetPos(ply:GetPos() + Vector(0, 0, 50))
			tombstone:Spawn()
			
			local weps = {}
			
			for k, v in pairs(ply:GetWeapons()) do table.insert(weps, {class = v:GetClass(), pap = v:HasNZModifier("pap")}) end
			
			local perks = ply.OldPerks
			
			tombstone.OwnerData.weps = weps
			tombstone.OwnerData.perks = perks
			
			ply:KillDownedPlayer()
			tombstone:SetPerkOwner(ply)
		end
	end)
	
	hook.Add("Think", "CheckDownedPlayersTime", function()
		for ent_index, player_data in pairs(nzRevive.Players) do
			if CurTime() - player_data.DownTime >= player_data.DownTimeMax and not player_data.ReviveTime then
				local ent = Entity(ent_index)
				
				if ent.KillDownedPlayer then ent:KillDownedPlayer()
				else
					--If it's a non-player entity, do the same thing just to clean up the table
					local revivor = player_data.RevivePlayer
					
					if IsValid(revivor) then revivor:StripWeapon("nz_revive_morphine") end
					
					nzRevive.Players[ent_index] = nil
				end
			end
		end
	end)
end

function nzRevive:CreateWhosWhoClone(ply, pos)
	local pos = pos or ply:GetPos()
	local wep = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() ~= "nz_perk_bottle" and ply:GetActiveWeapon():GetClass() or ply.oldwep or nil
	local weps = {}
	local who = ents.Create("whoswho_downed_clone")
	
	who:SetPos(pos + Vector(0,0,10))
	who:SetAngles(ply:GetAngles())
	who:Spawn()
	who:GiveWeapon(wep)
	who:SetPerkOwner(ply)
	who:SetModel(ply:GetModel())
	who.OwnerData.perks = ply.OldPerks or ply:GetPerks()
	
	for _, v in pairs(ply:GetWeapons()) do table.insert(weps, {class = v:GetClass(), pap = v:HasNZModifier("pap"), speed = v:HasNZModifier("speed"), dtap = v:HasNZModifier("dtap")}) end
	
	who.OwnerData.weps = weps
	
	timer.Simple(0.1, function()
		if IsValid(who) then
			local id = who:EntIndex()
			
			self.Players[id] = {}
			self.Players[id].DownTime = CurTime()
			self.Players[id].DownTimeMax = GetConVar("nz_downtime"):GetFloat()
			
			hook.Call("PlayerDowned", nzRevive, who)
		end
	end)
	
	ply.WhosWhoClone = who
	ply.WhosWhoMoney = 0
	
	net.Start("nz_WhosWhoActive")
	net.WriteBool(true)
	net.Send(ply)
end

function nzRevive:RespawnWithWhosWho(ply, pos)
	local pos = pos or nil

	if not pos then
		local available = ents.FindByClass("nz_spawn_zombie_special")
		local maxdist = 1500 ^ 2
		local mindist = 500 ^ 2
		local plypos = ply:GetPos()
		local spawns = {}
		
		if IsValid(available[1]) then
			for _, ent in pairs(available) do
				local dist = plypos:DistToSqr(ent:GetPos())
				
				if (not ent.link or nzDoors:IsLinkOpened(ent.link)) and dist < maxdist and dist > mindist and ent:IsSuitable() then table.insert(spawns, ent) end
			end
			
			--fall back, redo the search but without distance restriction
			if not IsValid(spawns[1]) then for _, ent in pairs(available) do if (not ent.link or nzDoors:IsLinkOpened(ent.link)) and ent:IsSuitable() then table.insert(spawns, ent) end end end
			
			--ANOTHER fall back, searches the spawn points
			if not IsValid(spawns[1]) then
				local pspawns = ents.FindByClass("player_spawns")
				
				if not IsValid(pspawns[1]) then ply:Spawn()
				else pos = pspawns[math.random(table.Count(pspawns))]:GetPos() end
			else pos = spawns[math.random(table.Count(spawns))]:GetPos() end
		else
			--there is no special spawnpoints, use regular player spawns
			local pspawns = ents.FindByClass("player_spawns")
			
			if not IsValid(pspawns[1]) then ply:Spawn()
			else pos = pspawns[math.random(#pspawns)]:GetPos() end
		end
	end
	
	ply:RevivePlayer()
	ply:StripWeapons()
	
	player_manager.RunClass(ply, "Loadout")

	if pos then ply:SetPos(pos) end
end
