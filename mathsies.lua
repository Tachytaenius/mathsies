-- math. Deterministic LuaJIT maths library.
-- By Tachytaenius.
-- MIT license.

-- TODO: Logarithms

local tau = 6.28318530717958647692
local sqrt, abs, floor, ceil, min, max, huge = math.sqrt, math.abs, math.floor, math.ceil, math.min, math.max, math.huge

local function sin(x)
	local over = floor(x / (tau/2)) % 2 == 0 -- Is the sinusoid over or under at this x?
	x = abs(x) % (tau/2) -- Boil it down to what matters
	local absolute = (32*x*(tau-2*x))/(5*tau^2+16*x^2-8*tau*x) -- Bhāskara I's sine approximation in terms of tau.
	return over and absolute or -absolute
end

local function asin(x)
	if x < -1 or x > 1 then
		error("x must be within [-1, 1]")
	end
	-- Formula given by Blue on Mathematics Stack Exchange. https://math.stackexchange.com/users/409/blue
	local resultForAbsoluteX = tau / 4*(1-2*sqrt((1-abs(x))/(4+abs(x))))
	return x < 0 and -resultForAbsoluteX or resultForAbsoluteX
end

local function cos(x)
	return sin(tau / 4 - x)
end

local function acos(x)
	return tau / 4 - asin(x)
end

local function tan(x)
	return sin(x)/cos(x)
end

local function atan(x)
	return asin(x/sqrt(1+x^2))
end

local function distance(x, y)
	return sqrt(x^2 + y^2)
end

local function angle(x, y)
	if x == 0 then
		x = 1
	end
	local a = atan(y/x)
	if x < 0 then
		a = a + tau/2
	end
	local theta = a % tau
	return theta
end

local function cartesianToPolar(x, y)
	return distance(x, y), angle(x, y)
end

local function polarToCartesian(r, theta)
	local x = r * cos(theta)
	local y = r * sin(theta)
	return x, y
end

local function round(x, y)
	y = y or 1
	return floor(x * y + 0.5) / y
end

local function sgn(x)
	if x > 0 then 
		return 1
	elseif x == 0 then 
		return 0
	else
		-- Did you hear about the mathematician who was afraid of negative numbers?
		-- He'd stop at nothing to avoid them.
		return -1
		
		-- Did you laugh at that? I hope you didn't, because zero is a number; the empty set is when things get nothingy.
		-- "Zero is the cardinality of nothing, therefore zero is nothing." As if.
	end
end

local function isInteger(x)
	return floor(x) == x
end

local function closestPointOnCircumference(px, py, cx, cy, r)
	local vx, vy = px - cx, py - cy
	local vl = distance(vx, vy) -- get length of vector from point to circle centre
	local ax, ay = cx + vx / vl * r, cy + cy / vl * r
	return ax, ay -- return the answer
end

local function tri(x)
	return abs((x-tau/4)%tau-tau/2)/(tau/4)-1
end

return {
	tau = tau,
	pi = tau / 2, -- LuaJIT will optimise "tau / 2" in code, so choose whichever you find personally gratifying. I use tau in this library.
	sin = sin,
	asin = asin,
	cos = cos,
	acos = acos,
	tan = tan,
	atan = atan,
	distance = distance,
	angle = angle,
	cartesianToPolar = cartesianToPolar,
	polarToCartesian = polarToCartesian,
	round = round,
	sgn = sgn,
	isInteger = isInteger,
	closestPointOnCircumference = closestPointOnCircumference,
	sqrt = sqrt,
	abs = abs,
	ceil = ceil,
	floor = floor,
	max = max,
	min = min,
	huge = huge,
	tri = tri,
	
	-- non-deterministic but faster, for use in graphics
	ndCos = math.cos,
	ndSin = math.sin,
	ndTan = math.tan,
	ndAcos = math.acos,
	ndAsin = math.asin,
	ndAtan = math.atan,
	ndLog = math.log,
	ndRandom = math.random
}

-- thanks for reading :-)
