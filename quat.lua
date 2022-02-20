local detmath
do
	pcall(function() detmath = require("lib.detmath") end)
end

local ffi = require("ffi")
ffi.cdef([=[
	typedef struct {
		float x, y, z, w;
	} quat;
]=])

local ffi_istype = ffi.istype

local rawnew = ffi.typeof("quat")
local function new(x, y, z, w)
	if x and y and z then
		if w then
			return rawnew(x, y, z, w)
		else
			return rawnew(x, y, z, 0)
		end
	else
		return rawnew(0, 0, 0, 1)
	end
end

local sqrt, sin, cos, acos = math.sqrt, math.sin, math.cos, math.acos
local detsin, detcos, detacos 
if detmath then
	detsin, detcos, detacos = detmath.sin, detmath.cos, detmath.acos
end

local function length(q)
	local x, y, z, w = q.x, q.y, q.z, q.w
	return sqrt(x * x + y * y + z * z + w * w)
end

local function normalise(q)
	local len = #q
	return rawnew(q.x / len, q.y / len, q.z / len, q.w / len)
end

local function inverse(q)
	return rawnew(-q.x, -q.y, -q.z, q.w)
end

local function dot(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
end

local function slerp(a, b, i)
	if a == b then return a end
	
	local cosHalfTheta = dot(a, b)
	local halfTheta = acos(cosHalfTheta)
	local sinHalfTheta = sqrt(1 - cosHalfTheta^2)
	
	return a * (sin((1 - i) * halfTheta) / sinHalfTheta) + b * (sin(i * halfTheta) / sinHalfTheta)
end

local detSlerp
if detmath then
	function detSlerp(a, b, i)
		if a == b then return a end
		
		local cosHalfTheta = dot(a, b)
		local halfTheta = acos(cosHalfTheta)
		local sinHalfTheta = sqrt(1 - cosHalfTheta*cosHalfTheta)
		
		return a * (detsin((1 - i) * halfTheta) / sinHalfTheta) + b * (detsin(i * halfTheta) / sinHalfTheta)
	end
end

local function fromAxisAngle(v)
	local angle = #v
	if angle == 0 then return rawnew(0, 0, 0, 1) end
	local axis = v / angle
	local s, c = sin(angle / 2), cos(angle / 2)
	return normalise(new(axis.x * s, axis.y * s, axis.z * s, c))
end

local detFromAxisAngle
if detmath then
	function detFromAxisAngle(v)
		local angle = #v
		if angle == 0 then return rawnew(0, 0, 0, 1) end
		local axis = v / angle
		local s, c = detsin(angle / 2), detcos(angle / 2)
		return normalise(new(axis.x * s, axis.y * s, axis.z * s, c))
	end
end

local function components(q)
	return q.x, q.y, q.z, q.w
end

local quat = setmetatable({
	new = new,
	length = length,
	normalise = normalise,
	normalize = normalise,
	inverse = inverse,
	dot = dot,
	slerp = slerp,
	detSlerp = detSlerp,
	fromAxisAngle = fromAxisAngle,
	detFromAxisAngle = detFromAxisAngle,
	components = components
}, {
	__call = function(_, x, y, z, w)
		return new(x, y, z, w)
	end
})

ffi.metatype("quat", {
	__unm = function(a)
		return rawnew(-a.x, -a.y, -a.z, -a.w)
	end,
	__mul = function(a, b)
		local isQuat = type(b) == "cdata" and ffi_istype("quat", b)
		if isQuat then
			return rawnew(
				a.x * b.w + a.w * b.x + a.y * b.z - a.z * b.y,
				a.y * b.w + a.w * b.y + a.z * b.x - a.x * b.z,
				a.z * b.w + a.w * b.z + a.x * b.y - a.y * b.x,
				a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z
			)
		else
			return rawnew(a.x * b, a.y * b, a.z * b, a.w * b)
		end
	end,
	__add = function(a, b)
		return rawnew(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w)
	end,
	__eq = function(a, b)
		local isQuat = type(b) == "cdata" and ffi_istype("quat", b)
		return isQuat and a.x == b.x and a.y == b.y and a.z == b.z and a.w == b.w
	end,
	__len = length,
	__tostring = function(a)
		return string.format("quat(%f, %f, %f, %f)", a.x, a.y, a.z, a.w)
	end
})

return quat
