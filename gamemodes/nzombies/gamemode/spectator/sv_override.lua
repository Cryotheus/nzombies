local hooks = hook.GetTable().AllowPlayerPickup or {}

for identifier in pairs(hooks) do hook.Remove("AllowPlayerPickup", identifier) end

--global functions
function GM:PlayerInitialSpawn(ply) timer.Simple(0, function() ply:SetSpectator() end) end

function GM:PlayerDeath(ply, wep, killer)
	ply:SetSpectator()
	ply:SetTargetPriority(TARGET_PRIORITY_NONE)
end

function GM:PlayerDeathThink(ply)
	-- Allow players in creative mode to respawn
	if ply:IsInCreative() and nzRound:InState(ROUND_CREATE) then
		if ply:KeyDown(IN_JUMP) or ply:KeyDown(IN_ATTACK) then
			ply:Spawn()
			
			return true
		end
	end
	
	local players = player.GetAllPlayingAndAlive()
	
	if ply:KeyPressed(IN_RELOAD)--[[ or ply:KeyPressed(IN_DUCK)]] then
		ply:SetSpectatingType(ply:GetSpectatingType() + 1)
		
		if ply:GetSpectatingType() > 5 then
			ply:SetSpectatingType(4)
			ply:SetupHands(players[ply:GetSpectatingID()])
		end
		
		ply:Spectate(ply:GetSpectatingType())
	elseif ply:KeyPressed(IN_ATTACK) then
		ply:SetSpectatingID(ply:GetSpectatingID() + 1)
		
		if ply:GetSpectatingID() > #players then ply:SetSpectatingID(1) end
		
		ply:SpectateEntity(players[ply:GetSpectatingID()])
	elseif ply:KeyPressed(IN_ATTACK2) then
		ply:SetSpectatingID(ply:GetSpectatingID() - 1)
		
		if ply:GetSpectatingID() <= 0 then ply:SetSpectatingID(#players) end
		
		ply:SpectateEntity(players[ply:GetSpectatingID()])
	end
end

--hooks
hook.Add("AllowPlayerPickup", "_nzDisableDeadPickups", function(ply, ent)
	if not ply:Alive() then return false
	else
		--this will allow pickups even if the weapon can't holster
		local wep = ply:GetActiveWeapon()
		
		if IsValid(wep) and not wep:IsSpecial() then
			local holster = wep.Holster
			wep.Holster = function() return true end
			
			timer.Simple(0, function() wep.Holster = holster end)
		end
		
		return true
	end
end)

hook.Add("PlayerUse", "nzDisableDeadUse", function(ply, ent)
	--don't let them use stuff when they're dead
	if not ply:Alive() then return false end
end)

hook.Add("Think", "nzSpectatorThinkPVS", function()
	for _, ply in pairs(player.GetHumans()) do
		if ply:GetObserverMode() > 0 then
			local target = ply:GetObserverTarget()
			
			if target then ply:SetPos(target:GetPos()) end
		end
	end
end)