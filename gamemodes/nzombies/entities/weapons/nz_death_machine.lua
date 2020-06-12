local shoot_sound = Sound("nz/deathmachine/loop_l_.wav")

if SERVER then
	AddCSLuaFile("nz_death_machine.lua")
	
	SWEP.Weight			= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= false
	
	function SWEP:NZSpecialHolster(wep)
		if IsValid(self.Owner) then
			print(self.Owner, self.WepOwner)
			
			self.Owner:RemovePowerUp("deathmachine", false)
		end
		
		return true
	end
	
	function SWEP:OnRemove()
		if not IsValid(self.WepOwner:GetActiveWeapon()) or not self.WepOwner:GetActiveWeapon():IsSpecial() then self.WepOwner:SetUsingSpecialWeapon(false) end
		
		self.WepOwner:SetActiveWeapon(nil)
		self.WepOwner:EquipPreviousWeapon()
	end
end

if CLIENT then
	SWEP.PrintName		= "Death Machine"			
	SWEP.Slot			= 1
	SWEP.SlotPos		= 1
	SWEP.DrawAmmo		= false
	SWEP.DrawCrosshair	= true
	
	SWEP.Category		= "nZombies"
end

SWEP.Author			= "Zet0r"
SWEP.Contact		= "youtube.com/Zet0r"
SWEP.Purpose		= "Bringing Death to Zombies since 1999"
SWEP.Instructions	= "Find a powerup to get it"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.HoldType = "shotgun"

SWEP.ViewModel = "models/weapons/c_zombies_deathmachine.mdl"
SWEP.WorldModel = "models/weapons/w_zombies_deathmachine.mdl"
SWEP.UseHands = true
SWEP.vModel = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.NZPreventBox = true
SWEP.NZTotalBlacklist = true
SWEP.NZSpecialCategory = "display" --this makes it count as special, as well as what category it replaces
--(display is generic stuff that should only be carried temporarily and never holstered and kept)

function SWEP:Initialize() self:SetHoldType(self.HoldType) end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	
	self.WepOwner = self.Owner
end

function SWEP:Equip(owner)
	owner:SetActiveWeapon("nz_death_machine")
	
	--let's not call a meta function every damn shot
	self.Damage = (nzRound:GetZombieHealth() or 75) * 3
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.05)
	self:EmitSound(shoot_sound)
	
	local bullet = {
		Damage = self.Damage,
		Dir = self.Owner:GetAimVector() + Vector(0, 0, 0),
		Force = 10,
		Spread = Vector(0.02, 0.02, 0),
		Src = self.Owner:GetShootPos(),
		Tracer = 1,
		TracerName = "AirboatGunHeavyTracer"
	}
	
	self.Owner:MuzzleFlash()
	self.Owner:FireBullets(bullet)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:PostDrawViewModel() end

function SWEP:GetViewModelPosition(pos, ang) return pos, ang end