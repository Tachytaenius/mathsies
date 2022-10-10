# Mathsies

LuaJIT maths library with support for floating point determinism.
By Tachytaenius.

## Notes

- Operations create and return new types, only changing the fields of a type (like `v.x = 3`) doesn't.
- The deterministic functions will be slower and less accurate than whatever your system provides.

## Modules

### `detmath`

Deterministic maths module.
Supplies Lua implementations of functions that may not give the same results on different machines if using the Lua `math` library.

#### Constants

- `tau`: Library-supplied (so guaranteed to be the same) constant for the ratio of a circle's circumference to its radius.
- `pi`: Library-supplied constant for the ratio of a circle's circumference to its diameter.
- `e`: Library supplied constant for Euler's number.

#### Functions

- `getRoundingMode()`: Detects and returns the rounding mode in use as a string.
	Should be specified and checked against for a game's input-based replay files.
- `exp(x)`: Returns `e` raised to the power of `x`.
- `pow(x, y)`: Returns `x` to the power of `y`.
	Currently has terrible error magnification.
- `intPow(x, n)`: Returns `x` raised to the power of `n` where `n` is an integer.
	This function exists because the IEEE 754 standard does not define exponentiation to an integer power as deterministic.
- `log(x)`: Returns the natural logarithm of `x`.
- `sin(x)`: Returns the sine of `x`, where `x` is in radians.
- `cos(x)`: Return the cosine of `x`, where `x` is in radians.
- `tan(x)`: Returns the tangent of `x`, where `x` is in radians.
- `asin(x)`: Returns the arcsine of `x` in radians.
- `acos(x)`: Returns the arccosine of `x` in radians.
- `atan(x)`: Returns the arctangent of `x` in radians.
- `atan2(y, x)`: Returns the "atan2" of the coordinates `x, y` in radians.
	Returns 0 when `x` and `y` both equate to 0, regardless as to the sign of the floats.
	Outputs in the range -tau/2 to tau/2.
- `sinh(x)`: Returns the hyperbolic sine of `x`.
- `cosh(x)`: Returns the hyperbolic cosine of `x`.
- `tanh(x)`: Returns the hyperbolic tangent of `x`.

### `vec2`

Supplies functionality for 2-dimensional vectors.
Has deterministic versions of its non-deterministic functions.
Calling the module is equivalent to calling its `new` function.

#### Types

- `vec2`: A 2-dimensional vector type.
	Supports addition, subtraction, negation, multiplication, division, modulo, equality testing, length, and `tostring`.
	Has fields `x` and `y`.

#### Functions

- `new(x, y`): Returns a new `vec2` with components `x` and `y`.
- `length(a)`: Returns the length of `vec2` `a`.
- `length2(a)`: Returns the square of the length of `vec2` `a`, faster than `length(a)`.
- `distance(a, b)`: Returns the distance between `vec2`s `a` and `b`.
- `distance2(a, b)`: Returns the square of the distance between `a` and `b`, faster than `distance(a, b)`.
- `dot(a, b)`: Returns the dot product of `vec2`s `a` and `b`.
- `normalise(a)`: Returns `a`, normalised.
- `normalize(a)`: Alias for `normalise(a)`.
- `reflect(incident, normal)`: Reflect a `vec2`.
- `refract(incident, normal, eta)`: Refract a `vec2`.
- `rotate(v, a)`: Rotate `vec2` `v` by angle `a` in radians.
- `detRotate(v, a)`: Deterministic version of `rotate(v, a)`.
- `fromAngle(a)`: Create a new `vec` from angle `a` in radians.
- `detFromAngle(a)`: Deterministic version of `fromAngle(a)`.
- `toAngle(v)`: Returns `atan2(v.y, v.x)`, in the range 0 to tau.
- `detToAngle(v)`: Deterministic version of `toAngle(v)`.
- `components(v)`: Returns `v.x, v.y`.
- `clone(v)`: Creates a new `vec2` identical to `v`.

### `vec3`

Supplies functionality for 3-dimensional vectors.
Has deterministic versions of its non-deterministic functions.
Calling the module is equivalent to calling its `new` function.

#### Types

- `vec3`: A 3-dimensional vector type.
	Supports addition, subtraction, negation, multiplication, division, modulo, equality testing, length, and `tostring`.
	Has fields `x`, `y`, and `z`.

#### Functions

- `new(x, y, z)`: Returns a new `vec3` with components `x`, `y`, and `z`.
- `length(a)`: Returns the length of `vec3` `a`.
- `length2(a)`: Returns the square of the length of `vec3` `a`, faster than `length(a)`.
- `distance(a, b)`: Returns the distance between `vec3`s `a` and `b`.
- `distance2(a, b)`: Returns the square of the distance between `a` and `b`, faster than `distance(a, b)`.
- `dot(a, b)`: Returns the dot product of `vec3`s `a` and `b`.
- `cross(a, b)`: Returns the cross product of `vec3`s `a` and `b`.
- `normalise(a)`: Returns `a`, normalised.
- `normalize(a)`: Alias for `normalise(a)`.
- `reflect(incident, normal)`: Reflect a `vec3`.
- `refract(incident, normal, eta)`: Refract a `vec3`.
- `rotate(v, q)`: Rotate `vec3` `v` with `quat` `q`.
- `fromAngles(theta, phi)`: Create a new `vec3` from horizontal angle `theta` and vertical angle `phi`.
- `detFromAngles(theta, phi)`: Deterministic version of `fromAngles(theta, phi)`.
- `components(v)`: Returns `v.x, v.y, v.z`.
- `clone(v)`: Returns a new `vec3` identical to `v`.

### `quat`

Supplies functionality for quaternions.
Has deterministic versions of its non-deterministic functions.
Calling the module is equivalent to calling its `new` function.

#### Types

- `quat`: A quaternion type.
	Supports negation, multiplication, addition, equality testing, length, and `tostring`.
	Has fields `x`, `y`, `z`, and `w`.

#### Functions

- `new(x, y, z, w)`: Returns a new `quat` with components `x`, `y`, `z`, and `w`.
- `length(q)`: Returns the length of a `quat` `q`.
- `normalise(q)`: Returns `q`, normalised.
- `normalize(q)`: Alias for `normalise(q)`.
- `inverse(q)`: Returns the inverse of `quat` `q`.
- `dot(a, b)`: Returns the dot product of `quat`s `a` and `b`.
- `slerp(a, b, i)`: Returns the spherical linear interpolation between `quat`s `a` and `b` with interpolation factor `i`.
- `detSlerp(a, b, i)`: Deterministic version of `slerp(a, b, i)`.
- `fromAxisAngle(v)`: Returns a new `quat` from axis-angle `vec3` `v`.
- `detFromAxisAngle(v)`: Deterministic version of `fromAxisAngle(v)`.
- `components(q)`: Returns `q.x, q.y, q.z, q.w`.
- `clone(q)`: Returns a new `quat` identical to `q`.

### `mat4`

Supplies functionality for 4x4 matrices.
Has deterministic versions of its non-deterministic functions.
Calling the module iss equivalent to calling its `new` function.

#### Types

- `mat4`: A 4x4 matrix type.
	Supports multiplication, equality testing, and `tostring`.
	Has fields `_00`,  `_01`,  `_02`,  `_03`,  `_10`,  `_11`,  `_12`,  `_13`,  `_20`,  `_21`,  `_22`,  `_23`,  `_30`,  `_31`,  `_32`, and `_33`.
	The underscores are there because you can't have a field name that starts with a number.
	The second character is the x position of the component and the third character is the y position of the component.

#### Functions

- `new(...)`: Creates a new `mat4` with components listed in the 16 arguments in the same order as fields.
- `perspectiveLeftHanded(aspect, vfov, far, near)`: Creates a left-handed perspective projection `mat4` from aspect ratio `aspect`, vertical field of view `vfov` (in radians), far plane distance `far` and near plane distance `near`.
- `detPerspectiveLeftHanded(aspect, vfov, far, near)`: Deterministic version of `perspectiveLeftHanded(aspect, vfov, far, near)`.
	Not recommended for use in actual 3D rendering.
- `perspectiveRightHanded(aspect, vfov, far, near)`: Creates a right-handed perspective projection `mat4` from aspect ratio `aspect`, vertical field of view `vfov` (in radians), far plane distance `far` and near plane distance `near`.
- `detPerspectiveRightHanded(aspect, vfov, far, near)`: Deterministic version of `perspectiveRightHanded(aspect, vfov, far, near)`.
	Not recommended for use in actual 3D rendering.
- `translate(v)`: Creates a translation `mat4` from `vec3` `v`.
- `rotate(q)`: Creates a rotation `mat4` from `quat` `q`.
- `scale(v)`: Creates a scale `mat4` from `vec3` `v`.
- `transform(t, r, s)`: Creates a transformation `mat4` from translation `vec3` `t`, rotation `quat` `r`, and scale `vec3` `s`.
- `camera(t, r, s)`: Creates a camera `mat4` from translation `vec3` `t`, rotation `quat` `r`, and scale `vec3` `s`.
- `components(m)`: Returns all the components of a `mat4` in the order described in the `mat4` type's description.
- `clone(m)`: Creates a new `mat4` identical to `m`.
- `inverse(m)`: Returns the inverse of `mat4` `m`.
- `transpose(m)`: Returns the transposition of `mat4` `m`.
