package game

import rl "vendor:raylib"
import "core:fmt"
import "core:strings"

vec2_inverse_lerp :: proc(value, start, end: rl.Vector2) -> f32 {
    ab := end - start
    av := value - start
    return rl.Vector2DotProduct(av, ab) / rl.Vector2DotProduct(ab, ab)
}


point_to_segment_distance_sq :: proc(p, a, b: rl.Vector2) -> f32 {
    ab := b - a
    ap := p - a

    ab_len_sq := rl.Vector2DotProduct(ab, ab)
    if ab_len_sq == 0 {
        return rl.Vector2DotProduct(ap, ap)
    }

    t := rl.Vector2DotProduct(ap, ab) / ab_len_sq
    t = clamp(t, 0, 1)

    closest := a + ab * t
    d := p - closest
    return rl.Vector2DotProduct(d, d)
}


format_with_commas :: proc(n: int, allocator := context.allocator) -> string {
    // Handle negative numbers
    negative := n < 0
    value := n if n >= 0 else -n

    // Convert to string first
    num_str := fmt.tprintf("%d", value)
    
    // Build result with commas
    buf: strings.Builder
    strings.builder_init(&buf, allocator)

    offset := len(num_str) % 3
    for i := 0; i < len(num_str); i += 1 {
        if i != 0 && (i - offset) % 3 == 0 {
            strings.write_byte(&buf, ',')
        }
        strings.write_byte(&buf, num_str[i])
    }

    result := strings.to_string(buf)
    if negative {
        return strings.concatenate({"-", result}, allocator)
    }
    return result
}