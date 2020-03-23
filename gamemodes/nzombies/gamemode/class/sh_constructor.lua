--this is only used in enemies/sv_spawner.lua

function nzClass(def, statics, base)
	if not def or type(def) ~= 'table' then error("class definition missing or not a table") end
	if statics and type(statics) ~= 'table' then error("statics parameter specified but not a table") end
	if base and (type(base) ~= 'table' or not isclass(base)) then error("base parameter specified but not a table created by class function") end
	
	local c = {__base__ = base}
	c.__class__ = c
	
	local function create(class_tbl, ...)
		local instanceObj = {}
		
		for i, v in pairs(c.__initprops__) do instanceObj[i] = v end
		
		setmetatable(instanceObj, { __index = c })
		
		if instanceObj.constructor then instanceObj:constructor(...) end
		
		return instanceObj
	end
	
	local c_mt = {__call = create}
	
	if base then c_mt.__index = base end
	
	if statics then
		for i, v in pairs(statics) do
			if type(v) ~= 'function' then c[i] = v
			else error("function definitions not supported in statics table") end
		end
	end
	
	c.__initprops__ = {}
	
	if base then for i, v in pairs(base.__initprops__) do c.__initprops__[i] = v end end
	
	for i,v in pairs(def) do
		if type(v) ~= 'function' then c.__initprops__[i] = v
		else c[i] = v end
	end
	
	c.__instanceof__ = function(instanceObj, classObj)
		local c = getclass(instanceObj)
		
		while c do
			if c == classObj then return true end
			
			c = c.__base__
		end
		
		return false
	end
	
	c.__getclass__ = function(instanceObj)
		local classObj = getmetatable(instanceObj).__index
		
		if isclass(classObj) then return classObj
		else return nil end
	end
	
	c.__getbase__ = function(classObj)
		if isclass(classObj) then return classObj.__base__
		else return nil end
	end
	
	setmetatable(c, c_mt)
	
	return c
end