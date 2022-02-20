-- Getting the same results from functions cross-platform

local tau = 6.28318530717958647692 -- Pi is also provided, of course :-)
local e = 2.71828182845904523536
local abs, floor, sqrt, modf, frexp, ldexp, huge = math.abs, math.floor, math.sqrt, math.modf, math.frexp, math.ldexp, math.huge

local getRoundingMode
do
	local modes = {
		nearest_toEven = {2, 2, -2, -2},
		nearest_truncate = {2, 3, -2, -3},
		truncate = {1, 2, -1, -2},
		ceiling = {2, 3, -1, -2},
		floor = {1, 2, -2, -3}
	}
	
	local input = {1.5, 2.5, -1.5, -2.5}
	
	local denormalSmallExponents = {
		half = -24,
		single = -149,
		double = -1074,
		quadruple = -16494,
		octuple = -262378
	}
	
	local normalSmallExponents = {
		half = -14,
		single = -126,
		double = -1022,
		quadruple = -16382,
		octuple = -262142
	}
	
	-- TODO: Test for all configurations
	function getRoundingMode(type, noDenormals)
		local small = ldexp(1, (noDenormals and normalSmallExponents or denormalSmallExponents)[type or "double"])
		
		for name, results in pairs(modes) do
			local this = true
			for i = 1, 4 do
				if small * input[i] ~= small * results[i] then
					this = false
					break
				end
			end
			if this then return name end
		end
	end
end

-- x raised to an integer is not deterministic
local function intPow(x, n) -- Exponentiation by squaring
	if n == 0 then
		return 1
	elseif n < 0 then
		x = 1 / x
		n = -n
	end
	local y = 1
	while n > 1 do
		if n % 2 == 0 then -- even
			n = n / 2
		else -- odd
			y = x * y
			n = (n - 1) / 2
		end
		x = x * x
	end
	return x * y
end

local function exp(x)
	local xint, xfract = modf(x)
	local exint = intPow(e, xint)
	local exfract = 1 + xfract + (xfract*xfract / 2) + (xfract*xfract*xfract / 6) + (xfract*xfract*xfract*xfract / 24) -- for n = 0, 4 sum xfract^n/n!
	return exint * exfract -- e ^ (xint + xfract)
end

local log
do
	local powerTable = { -- 1+2^-i
		1.5, 1.25, 1.125, 1.0625, 1.03125, 1.015625, 1.0078125, 1.00390625, 1.001953125, 1.0009765625, 1.00048828125, 1.000244140625, 1.0001220703125, 1.00006103515625, 1.000030517578125
	}
	local logTable = { -- log(1+2^-i)
		0.40546510810816438486, 0.22314355131420976486, 0.11778303565638345574, 0.06062462181643483994, 0.03077165866675368733, 0.01550418653596525448, 0.00778214044205494896, 0.00389864041565732289, 0.00195122013126174934, 0.00097608597305545892, 0.00048816207950135119, 0.00024411082752736271, 0.00012206286252567737, 0.00006103329368063853, 0.00003051711247318638
	}
	local ln2 = 0.69314718055994530942 -- log(2)
	function log(x)
		local xmant, xexp = frexp(x)
		if xmant == 0.5 then
			return ln2 * (xexp-1)
		end
		local arg = xmant * 2
		local prod = 1
		local sum = 0
		for i = 1, 15 do
			local prod2 = prod * powerTable[i]
			if prod2 < arg then
				prod = prod2
				sum = sum + logTable[i]
			end
		end
		return sum + ln2 * (xexp - 1)
	end
end

-- NOTE: Pretty big error magnification... :-/
local function pow(x, y)
	local yint, yfract = modf(y)
	local xyint = intPow(x, yint)
	local xyfract = exp(log(x)*yfract)
	return xyint * xyfract -- x ^ (yint + yfract)
end

local function sin(x)
	local over = floor(x / (tau / 2)) % 2 == 0 -- Get sign of sin(x)
	x = tau/4 - x % (tau/2) -- Shift x into domain of approximation
	local absolute = 1 - (20 * x*x) / (4 * x*x + tau*tau) -- https://www.desmos.com/calculator/o6gy67kqpg (should help to visualise what's going on)
	return over and absolute or -absolute
end

local function cos(x)
	local over = floor((tau/4 - x) / (tau / 2)) % 2 == 0
	x = tau/4 - (tau/4 - x) % (tau/2)
	local absolute = 1 - (20 * x*x) / (4 * x*x + tau*tau)
	return over and absolute or -absolute
end

local function tan(x)
	return sin(x)/cos(x)
end

local function asin(x)
	local positiveX, x = x > 0, abs(x)
	local resultForAbsoluteX = tau/4 - sqrt(tau*tau * (1 - x)) / (2 * sqrt(x + 4))
	return positiveX and resultForAbsoluteX or -resultForAbsoluteX
end

local function acos(x)
	local positiveX, x = x > 0, abs(x)
	local resultForAbsoluteX = sqrt(tau*tau * (1 - x)) / (2 * sqrt(x + 4)) -- Only approximates acos(x) when x > 0
	return positiveX and resultForAbsoluteX or -resultForAbsoluteX + tau/2
end

local function atan(x)
	x = x / sqrt(1 + x*x)
	local positiveX, x = x > 0, abs(x)
	local resultForAbsoluteX = tau/4 - sqrt(tau*tau * (1 - x)) / (2 * sqrt(x + 4))
	return positiveX and resultForAbsoluteX or -resultForAbsoluteX
end

local function arg(x, y)
	local theta = atan(y/x)
	theta = x == 0 and tau/4 * y / abs(y) or x < 0 and theta + tau/2 or theta
	return theta % tau -- The argument of complex number x+yi
end

-- Personally discouraged as I believe that, though the transition from atan to atan2 makes sense, the definition of the arctangent doesn't automatically make sense with two arguments
local function atan2(y, x)
	return arg(x, y)
end

local function sinh(x)
	local ex = exp(x)
	return (ex - 1/ex) / 2
end

local function cosh(x)
	local ex = exp(x)
	return (ex + 1/ex) / 2
end

local function tanh(x)
	local ex = exp(x)
	return (ex - 1/ex) / (ex + 1/ex)
end

return {
	getRoundingMode = getRoundingMode,
	
	tau = tau,
	pi = tau / 2, -- Choose whichever you find personally gratifying. I use tau in this library but it's up to you
	e = e,
	
	exp = exp,
	pow = pow,
	intPow = intPow,
	log = log,
	sin = sin,
	cos = cos,
	tan = tan,
	asin = asin,
	acos = acos,
	atan = atan,
	arg = arg,
	atan2 = atan2,
	sinh = sinh,
	cosh = cosh,
	tanh = tanh,
	-- TODO:
	asinh = asinh,
	acosh = acosh,
	atanh = atanh
}

-- Thanks!
