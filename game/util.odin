package game

import rl "vendor:raylib"
import "core:fmt"
import "core:math/rand"
import "core:strings"
import "base:intrinsics"

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


format_as_cstring :: proc(fstring: string, args: ..any) -> cstring {
    builder := strings.builder_make()
    defer strings.builder_destroy(&builder)
    formatted_string := fmt.sbprintf(&builder, fstring, ..args)
    return strings.clone_to_cstring(formatted_string)
}


indexof :: proc(arr: []$T, value: T) -> (int, bool) where intrinsics.type_is_comparable(T) {
    for v, i in arr {
        if v == value {
            return i, true
        }
    }
    return 0, false
}


play_random_sound :: proc(sounds: []rl.Sound) {
    sound := &sounds[rand.int_max(len(sounds))]
    rl.PlaySound(sound^)
}