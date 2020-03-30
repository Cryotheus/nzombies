
local function RegisterDefaultSpecialWeps()
	nzSpecialWeapons:AddKnife("nz_quickknife_crowbar", false, 0.65)
	nzSpecialWeapons:AddKnife("nz_bowie_knife", true, 0.65, 2.5)
	nzSpecialWeapons:AddKnife("nz_one_inch_punch", true, 0.75, 1.5)
	nzSpecialWeapons:AddKnife("tfa_cso_beam_sword", true, 0.3,  0.3)
	nzSpecialWeapons:AddKnife("tfa_cso_coldsteelblade", true, 0.4,  0.4)
	nzSpecialWeapons:AddKnife("tfa_cso_dragonblade", true, 0.5,  0.5)
	nzSpecialWeapons:AddKnife("tfa_cso_dragonblade_expert", true, 0.25,  0.25)
	nzSpecialWeapons:AddKnife("tfa_cso_serpent_blade", true, 0.3,  0.3)
	nzSpecialWeapons:AddKnife("tfa_cso_serpent_blade_expert", true, 0.15,  0.15)
	
	nzSpecialWeapons:AddKnife("tfa_cso_tomahawk", true, 0.6,  0.3)
	nzSpecialWeapons:AddKnife("tfa_cso_kujang", true, 0.4,  0.4)
	nzSpecialWeapons:AddKnife("tfa_cso_crowbarcraft", false, 0.4)
	nzSpecialWeapons:AddKnife("tfa_cso_jaysdagger", true, 0.6,  0.6)
	nzSpecialWeapons:AddKnife("tfa_cso_ruyi", true, 0.7,  0.5)
	nzSpecialWeapons:AddKnife("tfa_cso_hwando", true, 0.6,  0.6)
	nzSpecialWeapons:AddKnife("tfa_cso_mastercombatknife", true, 0.5,  0.3)
	nzSpecialWeapons:AddKnife("tfa_cso_katana", true, 0.5,  0.5)
	nzSpecialWeapons:AddKnife("tfa_cso_nata", true, 0.4,  0.5)
	nzSpecialWeapons:AddKnife("tfa_cso_snap_blade", true, 0.6,  0.2)
	nzSpecialWeapons:AddKnife("tfa_cso_sealknife", true, 0.7,  0.7)
	nzSpecialWeapons:AddKnife("tfa_cso_coldsteelblade", true, 0.3,  0.8)
	nzSpecialWeapons:AddKnife("tfa_cso_combatknife", true, 0.4,  0.7)
	nzSpecialWeapons:AddKnife("tfa_cso_janus9", true, 0.4,  0.8)
	nzSpecialWeapons:AddKnife("tfa_cso_butterflyknife", true, 0.4,  0.4)
	
	nzSpecialWeapons:AddGrenade("nz_grenade", 4, false, 0.85, false, 0.4) -- ALWAYS pass false instead of nil or it'll assume default value
	nzSpecialWeapons:AddGrenade("tfa_cso_sfgrenade", 4, false, 0.6, false, 0.4)
	nzSpecialWeapons:AddGrenade("tfa_cso_mooncake", 6, false, 1.5, false, 0.5)
	nzSpecialWeapons:AddGrenade("tfa_cso_holybomb_refined", 3, false, 1, false, 0.5)
	nzSpecialWeapons:AddGrenade("tfa_cso_m24grenade", 4, false, 0.9, false, 0.3)
	nzSpecialWeapons:AddGrenade("tfa_cso_heartbomb", 4, false, 0.7, false, 0.5)
	nzSpecialWeapons:AddGrenade("tfa_cso_cake", 1, false, 0.5, false, 0.3)
	nzSpecialWeapons:AddGrenade("tfa_cso_fragnade", 4, false, 0.8, false, 0.45)
	nzSpecialWeapons:AddGrenade("tfa_cso_chaingrenade", 4, false, 0.9, false, 0.5)
	nzSpecialWeapons:AddGrenade("tfa_cso_cartfrag", 4, false, 0.8, false, 0.4)
	
	nzSpecialWeapons:AddSpecialGrenade("nz_monkey_bomb", 3, false, 3, false, 0.4)
	nzSpecialWeapons:AddSpecialGrenade("tfa_cso_trinity_flame", 2, false, 1, false, 1)
	nzSpecialWeapons:AddSpecialGrenade("tfa_cso_trinity_stun", 2, false, 1, false, 1)
	
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