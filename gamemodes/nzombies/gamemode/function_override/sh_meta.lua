local already_exist = {}
local inviswalls = {
	["invis_damage_wall"] = true,
	["invis_wall"] = true,
	["wall_block"] = true}
local nz_pap_shooting_sound = CreateClientConVar("nz_pap_shooting_sound", "1", true, false, "Should the shooting sound overlay on Pack a Punch-ed weapons be used?", 0, 1)
local playerMeta = FindMetaTable("Player")
local wepMeta = FindMetaTable("Weapon")

local fl_game_AddAmmoType = game.AddAmmoType
local fl_wepMeta_DefaultReload = wepMeta.DefaultReload

if SERVER then
	function ReplaceAimDownSight(wep)
		local oldfire = wep.SecondaryAttack
		
		if not oldfire then return end
		
		wep.SecondaryAttack = function(...)
			oldfire(wep, ...)
			-- With deadshot, aim at the head of the entity aimed at --nice!
			if wep.Owner:HasPerk("deadshot") then
				local tr = wep.Owner:GetEyeTrace()
				local ent = tr.Entity
				
				if IsValid(ent) and nzConfig.ValidEnemies[ent:GetClass()] then
					local head = ent:LookupBone("ValveBiped.Bip01_Neck1")
					
					if head then
						local headpos,headang = ent:GetBonePosition(head)
						
						wep.Owner:SetEyeAngles((headpos - wep.Owner:GetShootPos()):Angle())
					end
				end
			end
		end
	end
	
	hook.Add("WeaponEquip", "nzModifyAimDownSights", ReplaceAimDownSight)
	
	hook.Add("DoAnimationEvent", "nzReloadCherry", function(ply, event, data)
		if event == PLAYERANIMEVENT_RELOAD then
			if ply:HasPerk("cherry") then
				local wep = ply:GetActiveWeapon()
				
				if IsValid(wep) and wep:Clip1() < wep:GetMaxClip1() then
					local ang = ply:GetAimVector()
					local d = DamageInfo()
					local percent = 1 - (wep:Clip1() / wep:GetMaxClip1())
					local pos = ply:GetPos() + ply:GetAimVector() * 10 + Vector(0, 0, 50)
					local zombies = ents.FindInSphere(ply:GetPos(), 250 * percent)
					
					nzEffects:Tesla({
						pos = ply:GetPos() + Vector(0, 0, 50),
						ent = ply,
						turnOn = true,
						dieTime = 1,
						lifetimeMin = 0.05 * percent,
						lifetimeMax = 0.1 * percent,
						intervalMin = 0.01,
						intervalMax = 0.02,
					})
					
					d:SetDamage(100 * percent)
					d:SetDamageType(DMG_SHOCK)
					d:SetAttacker(ply)
					d:SetInflictor(ply)
					
					for _, zombie in pairs(zombies) do if nzConfig.ValidEnemies[zombie:GetClass()] then zombie:TakeDamageInfo(d) end end
				end
			end
		end
	end)
	
	function GM:GetFallDamage(ply, speed)
		local damage = speed / 10
		
		if ply:HasPerk("phd") and damage >= 50 then
			if ply:Crouching() then
				local zombies = ents.FindInSphere(ply:GetPos(), 250)
				
				for k, zombie in pairs(zombies) do if nzConfig.ValidEnemies[zombie:GetClass()] then zombie:TakeDamage(800, ply, ply) end end
				
				local pos = ply:GetPos()
				local effect = EffectData()
				
				effect:SetOrigin(pos)
				
				util.Effect("HelicopterMegaBomb", effect)
				
				ply:EmitSound("phx/explode0" .. math.random(0, 6) .. ".wav")
			end
			
			return 0
		end
		
		return damage
	end
	
	local fl_playerMeta_SetActiveWeapon = playerMeta.SetActiveWeapon
	
	function playerMeta:SetActiveWeapon(wep)
		local oldwep = self:GetActiveWeapon()
		local wep = type(wep) == "string" and self:Give(wep) or wep
		
		if IsValid(oldwep) and not oldwep:IsSpecial() then self.NZPrevWep = oldwep end
		
		fl_playerMeta_SetActiveWeapon(self, wep)
	end
end

function wepMeta:DefaultReload(act)
	if IsValid(self.Owner) and self.Owner:HasPerk("speed") then return end
	
	fl_wepMeta_DefaultReload(self, act)
end

function GM:EntityFireBullets(ent, data)
	--fire the PaP shooting sound if the weapon is PaP'd
	if ent:IsPlayer() then
		local wep = ent:GetActiveWeapon()
		
		if IsValid(wep) and wep:HasNZModifier("pap") and nz_pap_shooting_sound:GetBool() and not wep.IsMelee and not wep.IsKnife then ent:EmitSound("nz/effects/pap_shoot_glock20.wav", 60, 100, 0.7) end
	end
	
	if ent:IsPlayer() and ent:HasPerk("dtap2") then return true end
end

function game.AddAmmoType(tbl)
	--[[game.AddAmmoType doesn't take duplicates into account and has a hardcoded limit of 128 --that's source for you
		which means our ammo types won't exist if we pass that limit with the countless duplicates :( 
		this doesn't work for lua scripts run before the gamemode, but should help for weapons adding ammo types on-the-fly!
		this will also prevent some ammo types from being added - that's fine. Our gamemode doesn't need them.]]
	if tbl.name and not already_exist[tbl.name] then
		fl_game_AddAmmoType(tbl)
		
		already_exist[tbl.name] = true
	end
end

hook.Add("ShouldCollide", "nz_InvisibleBlockFilter", function(ent1, ent2)
	--ghost invisible walls so nothing but players or NPCs collide with them
	if inviswalls[ent1:GetClass()] then return ent2:IsPlayer() or ent2:IsNPC()
	elseif inviswalls[ent2:GetClass()] then return ent1:IsPlayer() or ent1:IsNPC() end
end)