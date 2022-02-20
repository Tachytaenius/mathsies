local detmath
do
	pcall(function() detmath = require("lib.detmath") end)
end

local ffi = require("ffi")
ffi.cdef([=[
	typedef struct {
		float _00, _01, _02, _03, _10, _11, _12, _13, _20, _21, _22, _23, _30, _31, _32, _33;
	} mat4;
]=])

local ffi_istype = ffi.istype

local rawnew = ffi.typeof("mat4")
local function new(a,b,c,d, e,f,g,h, i,j,k,l, m,n,o,p)
	a = a or 1
	if not b then
		return rawnew(a,0,0,0, 0,a,0,0, 0,0,a,0, 0,0,0,a)
	else
		return rawnew(a,b,c,d, e,f,g,h, i,j,k,l, m,n,o,p)
	end
end

local tan = math.tan
local dettan
if detmath then
	dettan = detmath.tan
end

local function perspective(aspect, vfov, far, near)
	return rawnew(
		1/(aspect*tan(vfov/2)), 0, 0, 0,
		0, 1/tan(vfov/2), 0, 0,
		0, 0, (near+far)/(near-far), 2*(near+far)/(near-far),
		0, 0, -1, 0
	)
end

local detperspective
if detmath then
	-- The deterministic maths is really for cross-platform identical gamestate reproduction from inputs, but... might as well use it here (where it's used for output).
	function detperspective(aspect, vfov, far, near)
		return rawnew(
			1/(aspect*dettan(vfov/2)), 0, 0, 0,
			0, 1/dettan(vfov/2), 0, 0,
			0, 0, (near+far)/(near-far), 2*(near+far)/(near-far),
			0, 0, -1, 0
		)
	end
end

local function translate(v)
	return rawnew(
		1, 0, 0, v.x,
		0, 1, 0, v.y,
		0, 0, 1, v.z,
		0, 0, 0, 1
	)
end

local function rotate(q)
	local x, y, z, w = q.x, q.y, q.z, q.w
	return rawnew(
		1-2*y*y-2*z*z,   2*x*y-2*z*w,   2*x*z+2*y*w, 0,
		  2*x*y+2*z*w, 1-2*x*x-2*z*z,   2*y*z-2*x*w, 0,
		  2*x*z-2*y*w,   2*y*z+2*x*w, 1-2*x*x-2*y*y, 0,
		0, 0, 0, 1
	  )
end

local function scale(v)
	return rawnew(
		v.x, 0, 0, 0,
		0, v.y, 0, 0,
		0, 0, v.z, 0,
		0, 0, 0, 1
	)
end

local function transform(t, r, s)
	s = s or vec3(1)
	return translate(t) * rotate(r) * scale(s)
end

local function camera(t, r, s)
	s = s or vec3(1)
	return scale(1/s) * rotate(quat.inverse(r)) * translate(-t)
end

local function elements(m)
	return m._00,m._01,m._02,m._03, m._10,m._11,m._12,m._13, m._20,m._21,m._22,m._23, m._30,m._31,m._32,m._33
end

local function inverse(m)
	return rawnew(
		 m._11 * m._22 * m._33 - m._11 * m._23 * m._32 - m._21 * m._12 * m._33 + m._21 * m._13 * m._32 + m._31 * m._12 * m._23 - m._31 * m._13 * m._22,
		-m._01 * m._22 * m._33 + m._01 * m._23 * m._32 + m._21 * m._02 * m._33 - m._21 * m._03 * m._32 - m._31 * m._02 * m._23 + m._31 * m._03 * m._22,
		 m._01 * m._12 * m._33 - m._01 * m._13 * m._32 - m._11 * m._02 * m._33 + m._11 * m._03 * m._32 + m._31 * m._02 * m._13 - m._31 * m._03 * m._12,
		-m._01 * m._12 * m._23 + m._01 * m._13 * m._22 + m._11 * m._02 * m._23 - m._11 * m._03 * m._22 - m._21 * m._02 * m._13 + m._21 * m._03 * m._12,
		-m._10 * m._22 * m._33 + m._10 * m._23 * m._32 + m._20 * m._12 * m._33 - m._20 * m._13 * m._32 - m._30 * m._12 * m._23 + m._30 * m._13 * m._22,
		 m._00 * m._22 * m._33 - m._00 * m._23 * m._32 - m._20 * m._02 * m._33 + m._20 * m._03 * m._32 + m._30 * m._02 * m._23 - m._30 * m._03 * m._22,
		-m._00 * m._12 * m._33 + m._00 * m._13 * m._32 + m._10 * m._02 * m._33 - m._10 * m._03 * m._32 - m._30 * m._02 * m._13 + m._30 * m._03 * m._12,
		 m._00 * m._12 * m._23 - m._00 * m._13 * m._22 - m._10 * m._02 * m._23 + m._10 * m._03 * m._22 + m._20 * m._02 * m._13 - m._20 * m._03 * m._12,
		 m._10 * m._21 * m._33 - m._10 * m._23 * m._31 - m._20 * m._11 * m._33 + m._20 * m._13 * m._31 + m._30 * m._11 * m._23 - m._30 * m._13 * m._21,
		-m._00 * m._21 * m._33 + m._00 * m._23 * m._31 + m._20 * m._01 * m._33 - m._20 * m._03 * m._31 - m._30 * m._01 * m._23 + m._30 * m._03 * m._21,
		 m._00 * m._11 * m._33 - m._00 * m._13 * m._31 - m._10 * m._01 * m._33 + m._10 * m._03 * m._31 + m._30 * m._01 * m._13 - m._30 * m._03 * m._11,
		-m._00 * m._11 * m._23 + m._00 * m._13 * m._21 + m._10 * m._01 * m._23 - m._10 * m._03 * m._21 - m._20 * m._01 * m._13 + m._20 * m._03 * m._11,
		-m._10 * m._21 * m._32 + m._10 * m._22 * m._31 + m._20 * m._11 * m._32 - m._20 * m._12 * m._31 - m._30 * m._11 * m._22 + m._30 * m._12 * m._21,
		 m._00 * m._21 * m._32 - m._00 * m._22 * m._31 - m._20 * m._01 * m._32 + m._20 * m._02 * m._31 + m._30 * m._01 * m._22 - m._30 * m._02 * m._21,
		-m._00 * m._11 * m._32 + m._00 * m._12 * m._31 + m._10 * m._01 * m._32 - m._10 * m._02 * m._31 - m._30 * m._01 * m._12 + m._30 * m._02 * m._11,
		 m._00 * m._11 * m._22 - m._00 * m._12 * m._21 - m._10 * m._01 * m._22 + m._10 * m._02 * m._21 + m._20 * m._01 * m._12 - m._20 * m._02 * m._11
	)
end

local function transpose(m)
	return rawnew(m._00,m._10,m._20,m._30, m._01,m._11,m._21,m._31, m._02,m._12,m._22,m._32, m._03,m._13,m._23,m._33)
end

local mat4 = setmetatable({
	new = new,
	perspective = perspective,
	translate = translate,
	rotate = rotate,
	scale = scale,
	transform = transform,
	camera = camera,
	elements = elements,
	inverse = inverse,
	transpose = transpose
}, {
	__call = function(_, a,b,c,d, e,f,g,h, i,j,k,l, m,n,o,p)
		return new(a,b,c,d, e,f,g,h, i,j,k,l, m,n,o,p)
	end
})

ffi.metatype("mat4", {
	__mul = function(a, b)
		if type(b) == "number" then
			a, b = b, a
		end
		if type(a) == "number" then
			return rawnew(a*b._00,a*b._01,a*b._02,a*b._03, a*b._10,a*b._11,a*b._12,a*b._13, a*b._20,a*b._21,a*b._22,a*b._23, a*b._30,a*b._31,a*b._32,a*b._33)
		end
		if ffi_istype("vec3", b) then
			return vec3(
				(a._00 * b.x + a._01 * b.y + a._02 * b.z + a._03 * 1) / (a._30 * b.x + a._31 * b.y + a._32 * b.z + a._33 * 1),
				(a._10 * b.x + a._11 * b.y + a._12 * b.z + a._13 * 1) / (a._30 * b.x + a._31 * b.y + a._32 * b.z + a._33 * 1),
				(a._20 * b.x + a._21 * b.y + a._22 * b.z + a._23 * 1) / (a._30 * b.x + a._31 * b.y + a._32 * b.z + a._33 * 1)
			)
		end
		return rawnew(
			a._00 * b._00 + a._01 * b._10 + a._02 * b._20 + a._03 * b._30,
			a._00 * b._01 + a._01 * b._11 + a._02 * b._21 + a._03 * b._31,
			a._00 * b._02 + a._01 * b._12 + a._02 * b._22 + a._03 * b._32,
			a._00 * b._03 + a._01 * b._13 + a._02 * b._23 + a._03 * b._33,
			a._10 * b._00 + a._11 * b._10 + a._12 * b._20 + a._13 * b._30,
			a._10 * b._01 + a._11 * b._11 + a._12 * b._21 + a._13 * b._31,
			a._10 * b._02 + a._11 * b._12 + a._12 * b._22 + a._13 * b._32,
			a._10 * b._03 + a._11 * b._13 + a._12 * b._23 + a._13 * b._33,
			a._20 * b._00 + a._21 * b._10 + a._22 * b._20 + a._23 * b._30,
			a._20 * b._01 + a._21 * b._11 + a._22 * b._21 + a._23 * b._31,
			a._20 * b._02 + a._21 * b._12 + a._22 * b._22 + a._23 * b._32,
			a._20 * b._03 + a._21 * b._13 + a._22 * b._23 + a._23 * b._33,
			a._30 * b._00 + a._31 * b._10 + a._32 * b._20 + a._33 * b._30,
			a._30 * b._01 + a._31 * b._11 + a._32 * b._21 + a._33 * b._31,
			a._30 * b._02 + a._31 * b._12 + a._32 * b._22 + a._33 * b._32,
			a._30 * b._03 + a._31 * b._13 + a._32 * b._23 + a._33 * b._33
		)
	end,
	__eq = function(a, b)
		local isMat4 = ffi_istype("mat4", b)
		if isMat4 then
			for i = 1, 16 do
				if a[i] ~= b[i] then
					return false
				end
			end
			return true
		end
		return false
	end,
	__tostring = function(a)
		return string.format("mat4(%f,%f,%f,%f, %f,%f,%f,%f, %f,%f,%f,%f, %f,%f,%f,%f)", mat4.elements(a))
	end
})

return mat4
