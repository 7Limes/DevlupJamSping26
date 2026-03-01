package game

import "core:math"
import "core:math/rand"
import "core:fmt"
import rl "vendor:raylib"


WAVE_DURATION :: 15
WAVE_COOLDOWN_DURATION :: 3


WaveState :: enum {
    Idle,
    Ongoing
}


WaveData :: struct {
    state: WaveState,
    wave_number: int,
    wave_timer: f32,

    remaining_normal: int,
    remaining_big: int,
    remaining_huge: int,

    normal_interval, normal_time: f32,
    big_interval, big_time: f32,
    huge_interval, huge_time: f32
}


WAVE_ANIM_TABLE := [][4]f32 {
    {0, WIN_WIDTH, 50, 50},
    {WIN_WIDTH, 0, 50, 50},
    {0, WIN_WIDTH, 650, 650},
    {WIN_WIDTH, 0, 650, 650},
    {250, 250, -100, WIN_HEIGHT},
    {250, 250, WIN_HEIGHT, -100},
    {750, 750, -100, WIN_HEIGHT},
    {750, 750, WIN_HEIGHT, -100},
}

global_wave_anim: [4]f32


get_wave_enemies :: proc(wave_data: ^WaveData) {
    wave_number := wave_data.wave_number
    wave_data.remaining_normal = int(math.pow_f32(f32(wave_number), 1.3) + 5)
    wave_data.remaining_big = int(max(math.pow_f32(f32(wave_number), 1.15) - 5, 0.00001))
    wave_data.remaining_huge = int(max(math.pow_f32(f32(wave_number), 0.8) - 5, 0.00001))
    wave_data.normal_interval = WAVE_DURATION / f32(wave_data.remaining_normal)
    wave_data.big_interval = WAVE_DURATION / f32(wave_data.remaining_big)
    wave_data.huge_interval = WAVE_DURATION / f32(wave_data.remaining_huge)
    fmt.println(wave_data.normal_interval, wave_data.big_interval, wave_data.huge_interval)
}


get_money_bonus :: proc(wave_number: int) -> int {
    return int(100 * math.pow_f32(f32(wave_number), 0.2))
}


init_wave_data :: proc(wave_data: ^WaveData) {
    wave_data.state = .Idle
    wave_data.wave_number = 0
    wave_data.wave_timer = 0
}


next_wave :: proc(wave_data: ^WaveData) {
    wave_data.wave_timer = 0
    wave_data.state = .Ongoing
    wave_data.wave_number += 1
    wave_data.normal_time = 0
    wave_data.big_time = 0
    wave_data.huge_time = 0
    get_wave_enemies(wave_data)
    global_wave_anim = WAVE_ANIM_TABLE[rand.int_max(len(WAVE_ANIM_TABLE))]

    fmt.println("starting wave", wave_data.wave_number)
}

wave_update_ongoing :: proc(wave_data: ^WaveData, delta: f32) {
    // This sucks but it will work
    wave_data.wave_timer += delta
    wave_data.normal_time += delta
    added_normal := int(wave_data.normal_time / wave_data.normal_interval)
    if added_normal > 0 {
        for i in 0..<added_normal {
            if wave_data.remaining_normal > 0 {
                create_normal_enemy(&global_enemies)
                wave_data.remaining_normal -= 1
            }
        }
        wave_data.normal_time -= wave_data.normal_interval * f32(added_normal)
    }

    wave_data.big_time += delta
    added_big := int(wave_data.big_time / wave_data.big_interval)
    if added_big > 0 {
        for i in 0..<added_big {
            if wave_data.remaining_big > 0 {
                create_big_enemy(&global_enemies)
                wave_data.remaining_big -= 1
            }
        }
        wave_data.big_time -= wave_data.big_interval * f32(added_big)
    }

    wave_data.huge_time += delta
    added_huge := int(wave_data.huge_time / wave_data.huge_interval)
    if added_huge > 0 {
        for i in 0..<added_huge {
            if wave_data.remaining_huge > 0 {
                create_huge_enemy(&global_enemies)
                wave_data.remaining_huge -= 1
            }
        }
        wave_data.huge_time -= wave_data.huge_interval * f32(added_huge)
    }

    if wave_data.wave_timer >= WAVE_DURATION && len(global_enemies) == 0 {
        fmt.println("wave finished")
        wave_data.state = .Idle
        wave_data.wave_timer = 0
        global_money += get_money_bonus(wave_data.wave_number)
    }
}


wave_update :: proc(wave_data: ^WaveData, delta: f32) {
    switch wave_data.state {
        case .Idle:
            wave_data.wave_timer += delta
            if wave_data.wave_timer >= WAVE_COOLDOWN_DURATION {
                next_wave(wave_data)
            }
        case .Ongoing:
            wave_update_ongoing(wave_data, delta)
    }
}


draw_wave_label :: proc(wave_data: ^WaveData) {
    rl.GuiPanel({0, 0, 200, 100}, "Wave")
    saved_text_size := rl.GuiGetStyle(.DEFAULT, 16)
    rl.GuiSetStyle(.DEFAULT, 16, 30)
    
    rl.GuiLabel({10, 20, 200, 50}, format_as_cstring("Wave %d", wave_data.wave_number))

    rl.GuiSetStyle(.DEFAULT, 16, saved_text_size)
}


draw_animated_wave_label :: proc(wave_data: ^WaveData) {
    if wave_data.state == .Ongoing && wave_data.wave_timer <= 3.0 {
        saved_text_size := rl.GuiGetStyle(.DEFAULT, 16)
        rl.GuiSetStyle(.DEFAULT, 16, 80)
        t := wave_data.wave_timer / 3.0
        label_x := rl.Lerp(global_wave_anim[0], global_wave_anim[1], t)
        label_y := rl.Lerp(global_wave_anim[2], global_wave_anim[3], t)
        rl.GuiLabel({label_x, label_y, 300, 100}, format_as_cstring("Wave %d", wave_data.wave_number))
        rl.GuiSetStyle(.DEFAULT, 16, saved_text_size)
    }
}
