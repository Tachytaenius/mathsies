local detmath
do
	pcall(function() detmath = require("lib.detmath") end)
end

local ffi = require("ffi")
ffi.cdef([=[
	typedef struct {
		float x, y, z;
	} vec3;
]=])

local ffi_istype = ffi.istype

local rawnew = ffi.typeof("vec3")
local function new(x, y, z)
	x = x or 0
	y = y or x
	z = z or y
	return rawnew(x, y, z)
end

local sqrt, sin, cos = math.sqrt, math.sin, math.cos
local detsin, detcos 
if detmath then
	detsin, detcos = detmath.sin, detmath.cos
end

local function length(a)
	local x, y, z = a.x, a.y, a.z
	return sqrt(x * x + y * y + z * z)
end

local function length2(a)
	local x, y, z = a.x, a.y, a.z
	return x * x + y * y + z * z
end

local function distance(a, b)
	local x, y, z = b.x - a.x, b.y - a.y, b.z - a.z
	return sqrt(x * x + y * y + z * z)
end

local function distance2(a, b)
	local x, y, z = b.x - a.x, b.y - a.y, b.z - a.z
	return x * x + y * y + z * z
end

local function dot(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z
end

local function cross(a, b)
	return rawnew(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
end

local function normalise(a)
	return a/length(a)
end

local function reflect(incident, normal)
	return incident - 2 * dot(normal, incident) * normal
end

local function refract(incident, normal, eta)
	local ndi = dot(normal, incident)
	local k = 1 - eta * eta * (1 - ndi * ndi)
	if k < 0 then
		return rawnew(0, 0)
	else
		return eta * incident - (eta * ndi + sqrt(k)) * normal
	end
end

local function rotate(v, q)
	local qxyz = new(q.x, q.y, q.z)
	local uv = cross(qxyz, v)
	local uuv = cross(qxyz, uv)
	return v + ((uv * q.w) + uuv) * 2
end

local function fromAngles(theta, phi)
	local st, sp, ct, cp = sin(theta), sin(phi), cos(theta), cos(phi)
	return rawnew(st*sp,ct,st*cp)
end

local detFromAngles
if detmath then
	function detFromAngles(theta, phi)
		local st, sp, ct, cp = detsin(theta), detsin(phi), detcos(theta), detcos(phi)
		return rawnew(st*sp,ct,st*cp)
	end
end

local function components(v)
	return v.x, v.y, v.z
end

local vec3 = setmetatable({
	new = new,
	length = length,
	length2 = length2,
	distance = distance,
	distance2 = distance2,
	dot = dot,
	cross = cross,
	normalise = normalise,
	normalize = normalise,
	reflect = reflect,
	refract = refract,
	rotate = rotate,
	fromAngles = fromAngles,
	detFromAngles = detFromAngles,
	components = components
}, {
	__call = function(_, x, y, z)
		return new(x, y, z)
	end
})

ffi.metatype("vec3", {
	__add = function(a, b)
		if type(a) == "number" then
			return rawnew(a + b.x, a + b.y, a + b.z)
		elseif type(b) == "number" then
			return rawnew(a.x + b, a.y + b, a.z + b)
		else
			return rawnew(a.x + b.x, a.y + b.y, a.z + b.z)
		end
	end,
	__sub = function(a, b)
		if type(a) == "number" then
			return rawnew(a - b.x, a - b.y, a - b.z)
		elseif type(b) == "number" then
			return rawnew(a.x - b, a.y - b, a.z - b)
		else
			return rawnew(a.x - b.x, a.y - b.y, a.z - b.z)
		end
	end,
	__unm = function(a)
		return rawnew(-a.x, -a.y, -a.z)
	end,
	__mul = function(a, b)
		if type(a) == "number" then
			return rawnew(a * b.x, a * b.y, a * b.z)
		elseif type(b) == "number" then
			return rawnew(a.x * b, a.y * b, a.z * b)
		else
			return rawnew(a.x * b.x, a.y * b.y, a.z * b.z)
		end
	end,
	__div = function(a, b)
		if type(a) == "number" then
			return rawnew(a / b.x, a / b.y, a / b.z)
		elseif type(b) == "number" then
			return rawnew(a.x / b, a.y / b, a.z / b)
		else
			return rawnew(a.x / b.x, a.y / b.y, a.z / b.z)
		end
	end,
	__mod = function(a, b)
		if type(a) == "number" then
			return rawnew(a % b.x, a % b.y, a % b.z)
		elseif type(b) == "number" then
			return rawnew(a.x % b, a.y % b, a.z % b)
		else
			return rawnew(a.x % b.x, a.y % b.y, a.z % b.z)
		end
	end,
	__eq = function(a, b)
		local isVec3 = type(b) == "cdata" and ffi_istype("vec3", b)
		return isVec3 and a.x == b.x and a.y == b.y and a.z == b.z
	end,
	__len = length,
	__tostring = function(a)
		return string.format("vec3(%f, %f, %f)", a.x, a.y, a.z)
	end
})

return vec3
