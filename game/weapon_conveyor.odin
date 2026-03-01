package game

import rl "vendor:raylib"
import "core:math"
import "core:fmt"
import "core:math/rand"


WEAPON_PRICE :: 50

PANEL_WIDTH :: 200
PANEL_HEIGHT :: 800

CONVEYOR_RECT :: rl.Rectangle{50, 150, 100, 400}
CONVEYOR_BOTTOM :: CONVEYOR_RECT.y+CONVEYOR_RECT.height

BOX_RECT :: rl.Rectangle{CONVEYOR_RECT.x, CONVEYOR_RECT.y-100, 100, 100}
BOX_SPEED :: 1.0

WEAPON_ICON_SCALE :: 1.5

WeaponBox :: struct {
    rect: rl.Rectangle,
    weapon: WeaponType
}

conveyor_contents: [dynamic]WeaponBox
max_conveyor_boxes := 3
conveyor_sprite_positions: [6]rl.Vector2
conveyor_sprites_initialized := false


update_weapon_conveyor :: proc() {
    if !conveyor_sprites_initialized {
        // Initialize
        for i in 0..<cap(conveyor_sprite_positions) {
            pos := rl.Vector2{CONVEYOR_RECT.x, CONVEYOR_RECT.y+f32(i-1)*100}
            conveyor_sprite_positions[i] = pos
        }
        conveyor_sprites_initialized = true
    }

    for &pos in conveyor_sprite_positions {
        pos.y += 1
        if pos.y > CONVEYOR_BOTTOM {
            pos.y = CONVEYOR_RECT.y-100
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
    
    for &sprite_pos in conveyor_sprite_positions {
        rl.DrawTextureEx(TEX_CONVEYOR, sprite_pos, 0, 6.25, rl.WHITE)
    }
    
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
    
    // Cover up top and bottom
    bg_color := rl.GetColor(u32(rl.GuiGetStyle(.DEFAULT, 19)))
    rl.DrawRectangle(i32(CONVEYOR_RECT.x), i32(CONVEYOR_RECT.y-100), 100, 100, bg_color)
    rl.DrawRectangle(i32(CONVEYOR_RECT.x), i32(CONVEYOR_BOTTOM), 100, 100, bg_color)
    rl.DrawRectangleLinesEx(CONVEYOR_RECT, 3, rl.BLACK)

    saved_text_size := rl.GuiGetStyle(.DEFAULT, 16)
    rl.GuiSetStyle(.DEFAULT, 16, 19)

    if rl.GuiButton({25, 575, 150, 70}, "Buy Weapon ($50)") {
        if global_money >= WEAPON_PRICE && len(conveyor_contents) < max_conveyor_boxes {
            global_money -= WEAPON_PRICE
            add_weapon_box()
        }
    }

    rl.GuiSetStyle(.DEFAULT, 16, saved_text_size)
}