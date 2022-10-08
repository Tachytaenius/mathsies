# Mathsies

LuaJIT maths library with support for floating point determinism.
By Tachytaenius.

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
- `intPow(x, n)`: Returns `x` raised to the power of `n` where `n` is an integer.
	This function exists because the IEEE 754 standard does not define exponentiation to an integer power as deterministic.
- `log(x)`: Returns the natural logarithm of `x`.
- `sin(x)`: Returns the sine of `x`, where `x` is in radians.
- `cos(x)`: Return the cosine of `x`, where `x` is in radians.
- `tan(x)`: Returns the tangent of `x`, where `x` is in radians.
- `asin(x)`: Returns the arcsine of `x` in radians.
- `acos(x)`: Returns the arccosine of `x` in radians.
- `atan(x)`: Returns the arctangent of `x` in radians.
- `arg(x, y)`: Returns the argument of the complex number `x + yi` in radians.
	Equivalent to `atan2(y, x)`.
- `atan2(y, x)`: Returns the "atan2" of the coordinates `x, y` in radians.
	Equivalent to `arg(x, y)`.
- `sinh(x)`: Returns the hyperbolic sine of x.
- `cosh(x)`: Returns the hyperbolic cosine of x.
- `tanh(x)`: Returns the hyperbolic tangent of x.

### `vec2`

Supplies functionality for 2-dimensional vectors. Has deterministic versions of its non-deterministic functions.

#### Functions

TODO

### `vec3`

Supplies functionality for 3-dimensional vectors. Has deterministic versions of its non-deterministic functions.

#### Functions

TODO

### `quat`

Supplies functionality for quaternions. Has deterministic versions of its non-deterministic functions.

#### Functions

TODO

### `mat4`

Supplies functionality for 4x4 matrices. Has deterministic versions of its non-deterministic functions.

#### Functions

TODO
