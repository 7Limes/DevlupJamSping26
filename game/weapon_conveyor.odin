package game

import rl "vendor:raylib"
import "core:math"
import "core:fmt"
import "core:math/rand"


PANEL_WIDTH :: 200
PANEL_HEIGHT :: 800

CONVEYOR_RECT :: rl.Rectangle{50, 100, 100, 500}
CONVEYOR_BOTTOM :: CONVEYOR_RECT.y+CONVEYOR_RECT.height

BOX_RECT :: rl.Rectangle{CONVEYOR_RECT.x, CONVEYOR_RECT.y-100, 100, 100}
BOX_SPEED :: 1.0

WEAPON_ICON_SCALE :: 1.5

GENERATE_INTERVAL :: 10.0

WeaponBox :: struct {
    rect: rl.Rectangle,
    weapon: WeaponType
}

conveyor_contents: [dynamic]WeaponBox
generate_timer: f32 = 0.0
max_conveyor_boxes := 3


update_weapon_conveyor :: proc(delta: f32) {
    generate_timer -= delta
    if generate_timer < 0 {
        generate_timer = GENERATE_INTERVAL
        if len(conveyor_contents) < max_conveyor_boxes {
            add_weapon_box()
        }
    }

    for i := 0; i < len(conveyor_contents); i+=1 {
        box := &conveyor_contents[i]
        box_bottom := box.rect.y+box.rect.height
        can_move_down := box_bottom < CONVEYOR_BOTTOM
        if i > 0 {
            prev_box := conveyor_contents[i-1]
            can_move_down = can_move_down && box_bottom < prev_box.rect.y
        }

        if can_move_down {
            box.rect.y = math.clamp(box.rect.y+BOX_SPEED, 0, CONVEYOR_BOTTOM)
        }
    }
}


add_weapon_box :: proc() {
    type := WeaponType(rand.int_max(len(WeaponType)))
    box := WeaponBox{BOX_RECT, type}
    append(&conveyor_contents, box)
}


show_weapon_conveyor_ui :: proc(weapon_data: ^WeaponData) {
    rl.GuiPanel({0, 0, PANEL_WIDTH, PANEL_HEIGHT}, "Weapons")
    
    for i := 0; i < len(conveyor_contents); i+=1 {
        box := conveyor_contents[i]
        tooltip_data := WEAPON_TOOLTIPS[box.weapon]
        if (tooltip_button(box.rect, "", tooltip_data[0], tooltip_data[1])) {
            change_weapon(weapon_data, box.weapon)
            ordered_remove(&conveyor_contents, i)
            i -= 1
        }
        weapon_tex := WEAPON_TEXTURES[box.weapon]
        rl.DrawTextureEx(weapon_tex, {box.rect.x, box.rect.y+70}, -45, WEAPON_ICON_SCALE, rl.WHITE)
    }

    rl.DrawRectangleLinesEx(CONVEYOR_RECT, 3, rl.BLACK)
}