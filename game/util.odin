package game

import rl "vendor:raylib"

vec2_inverse_lerp :: proc(value, start, end: rl.Vector2) -> f32 {
    ab := end - start
    av := value - start
    return rl.Vector2DotProduct(av, ab) / rl.Vector2DotProduct(ab, ab)
}