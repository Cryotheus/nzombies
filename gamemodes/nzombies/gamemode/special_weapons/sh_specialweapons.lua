
local function RegisterDefaultSpecialWeps()
	nzSpecialWeapons:AddKnife("nz_quickknife_crowbar", false, 0.65)
	nzSpecialWeapons:AddKnife("nz_bowie_knife", true, 0.65, 2.5)
	nzSpecialWeapons:AddKnife("nz_one_inch_punch", true, 0.75, 1.5)
	nzSpecialWeapons:AddKnife("tfa_cso_beam_sword", true, 0.3,  0.3)
	nzSpecialWeapons:AddKnife("tfa_cso_coldsteelblade", true, 0.4,  0.4)
	nzSpecialWeapons:AddKnife("tfa_cso_dragonblade", true, 0.5,  0.5)
	nzSpecialWeapons:AddKnife("tfa_cso_dragonblade_expert", true, 0.25,  0.25)
	nzSpecialWeapons:AddKnife("tfa_cso_serpent_blade", true, 0.3,  0.3)
	
	nzSpecialWeapons:AddGrenade("nz_grenade", 4, false, 0.85, false, 0.4) -- ALWAYS pass false instead of nil or it'll assume default value
	nzSpecialWeapons:AddSpecialGrenade("nz_monkey_bomb", 3, false, 3, false, 0.4)
	
	nzSpecialWeapons:AddDisplay("nz_revive_morphine", false, function(wep)
		return not (IsValid(wep.Owner:GetPlayerReviving()) and wep.Owner:KeyDown(IN_USE))
	end)
	
	nzSpecialWeapons:AddDisplay("nz_perk_bottle", false, function(wep)
		return SERVER and CurTime() > wep.nzDeployTime + 3.1
	end)
	
	nzSpecialWeapons:AddDisplay("nz_packapunch_arms", false, function(wep)
		return SERVER and CurTime() > wep.nzDeployTime + 2.5
	end)
end

hook.Add("InitPostEntity", "nzRegisterSpecialWeps", RegisterDefaultSpecialWeps)