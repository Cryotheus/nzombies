AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "random_box_spawns"
ENT.Author			= "Zet0r"
ENT.Contact			= "Don't"
ENT.Purpose			= "Spawn points for random_box entities."
ENT.Instructions	= "Created in the nZombies creative mode."

function ENT:Initialize()
	self:SetModel("models/nzprops/mysterybox_pile.mdl")
	self:SetColor(color_white)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	
	self:PhysicsInit(SOLID_VPHYSICS)
	
	self:GetPhysicsObject():EnableMotion(false)
end