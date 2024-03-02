# Changelog

Doesn't record changes in the readme.

## Version 11

- Fixed projection matrices
- Removed empty indented lines

## Version 10

- Removed `detmath.arg(x, y)`.
- Made `detmath.atan2(y, x)` return angle in the range [-tau/2, tau/2].
- Added `vec2.toAngle(v)` and `vec2.detToAngle(v)`.

## Version 9

- Cleaned up the comments in the code, moving them to GitHub issues.
- Changed some argument names from `a` to `v`.
- Added `vec2.fromAngle(a)`.
- Fix bug where normal `cos` was used instead of `detacos` in `detSlerp`.
- Capitalised `detsin` etc to `detSin`.
