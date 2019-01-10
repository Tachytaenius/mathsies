local metadata = {
	name = "Mathsies",
	description = "Deterministic maths functions for LuaJIT.",
	version = "0.1.0",
	author = "Tachytaenius",
	license = [[
		MIT License
		
		Copyright (c) 2018 Henry Fleminger Thomson
		
		Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
		
		The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	]]
}

-- TODO: Logarithms, exponentiation

local tau = 6.28318530717958647692
local phi = 1.61803398874989484820
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

local function cot(x)
	return cos(x)/sin(x)
end

local function acot(x)
	return acos(x/sqrt(1+x^2))
end

local function distance(x, y)
	return sqrt(x^2 + y^2)
end

local function angle(x, y)
	x = x == 0 and 1 or x
	local a = atan(y/x)
	a = x < 0 and a + tau / 2 or a
	return a % tau
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
	-- Did you hear about the mathematician who was afraid of negative numbers?
	-- He'd stop at nothing to avoid them.
	return x == 0 and 0 or abs(x) / x
	-- Did you laugh at that? I hope you didn't, because zero is a number; the empty set is when things get nothingy.
	-- "Zero is the cardinality of nothing, therefore zero is nothing." As if.
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

local function int(a, b, f, n, i, ...)
	n = n or 256
	i = i or 1
	if a > b then
		a, b =  b, a
	end
	local sum = 0
	table.insert(arg, i, _)
	for v = a, b - (b - a) / n, (b - a) / n do
		arg[i] = v
		sum = sum + f(unpack(arg)) * (b - a) / n
	end
	return sum
end

local function tri(x)
	return abs((x-tau/4)%tau-tau/2)/(tau/4)-1
end

local function real(x)
	return x == x and abs(x) ~= huge
end

local function isNan(x)
	return x ~= x
end

local function isInfinite(x)
	return abs(x) == huge
end

local function clamp(lower, x, upper)
	return max(0, min(x, upper))
end

return {
	metadata = metadata,
	
	tau = tau,
	phi = phi,
	pi = tau / 2, -- LuaJIT will optimise "tau / 2" in code, so choose whichever you find personally gratifying. I use tau in this library.
	sin = sin,
	asin = asin,
	cos = cos,
	acos = acos,
	tan = tan,
	atan = atan,
	cot = cot,
	acot = acot,
	int = int,
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
	real = real,
	isNan = isNan,
	isInfinite = isInfinite,
	clamp = clamp,
	
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
