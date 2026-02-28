package game

import "core:fmt"
import "core:math/rand"
import "core:math"
import "core:strings"
import rl "vendor:raylib"

WIN_WIDTH :: 800
WIN_HEIGHT :: 800

CENTER :: rl.Vector2{WIN_WIDTH/2, WIN_HEIGHT/2}

PLAYER_RADIUS :: 30
PLAYER_TURN_SPEED :: 0.08
PLAYER_LINE_LENGTH :: 60
SHOOT_SPEED :: 5.0
PLAYER_COLOR :: rl.Color{50, 50, 220, 255}
PLAYER_OUTLINE_COLOR :: rl.Color{30, 30, 170, 255}

BULLET_RADIUS :: 5
BULLET_COLOR :: rl.Color{220, 220, 50, 255}
BULLET_OUTLINE_COLOR :: rl.Color{120, 120, 20, 255}

HIGH_HEALTH_COLOR :: rl.LIME
LOW_HEALTH_COLOR :: rl.RED

Player :: struct {
    facing_vector: rl.Vector2,
    weapon_data: WeaponData
}

// Update procedures
update_player :: proc(player: ^Player) {
    player.facing_vector = rl.Vector2Normalize(rl.GetMousePosition() - CENTER)

    // Handle firing
    if rl.IsKeyDown(rl.KeyboardKey.RIGHT_SHIFT) || rl.IsKeyDown(rl.KeyboardKey.LEFT_SHIFT) {
        shoot_point := CENTER + player.facing_vector * PLAYER_LINE_LENGTH
        shot := shoot_weapon(&player.weapon_data, shoot_point, player.facing_vector)
    }
}


// Drawing procedures
draw_player :: proc(player: ^Player) {
    line_end := CENTER + player.facing_vector * PLAYER_LINE_LENGTH

    rl.DrawCircle(i32(CENTER.x), i32(CENTER.y), PLAYER_RADIUS+5, PLAYER_OUTLINE_COLOR)
    rl.DrawCircle(i32(CENTER.x), i32(CENTER.y), PLAYER_RADIUS, PLAYER_COLOR)
    rl.DrawLineEx(CENTER, line_end, 10, rl.DARKGRAY)
}

draw_bullets :: proc(bullets: ^#soa[dynamic]Bullet) {
    for bullet in bullets {
        rl.DrawCircle(i32(bullet.position.x), i32(bullet.position.y), BULLET_RADIUS+2, BULLET_OUTLINE_COLOR)
        rl.DrawCircle(i32(bullet.position.x), i32(bullet.position.y), BULLET_RADIUS, BULLET_COLOR)
    }
}

draw_formatted_label :: proc(fstring: string, x, y, font_size: i32, color: rl.Color, args: ..any) {
    builder := strings.builder_make()
    formatted_string := fmt.sbprintf(&builder, fstring, ..args)
    formatted_cstring := strings.clone_to_cstring(formatted_string)
    rl.DrawText(formatted_cstring, x, y, font_size, color)
    strings.builder_destroy(&builder)
}

main :: proc() {
    
    player := Player{rl.Vector2{0, -1}, create_weapon_data()}
    defer delete_weapon_data(&player.weapon_data)

    enemies: #soa[dynamic]Enemy
    defer delete_soa(enemies)
    
    rl.SetConfigFlags(rl.ConfigFlags{rl.ConfigFlag.MSAA_4X_HINT})
    rl.InitWindow(WIN_WIDTH, WIN_HEIGHT, "window title")
    rl.SetTargetFPS(60)


    next_enemy_timer := 90

    for !rl.WindowShouldClose() {
        update_player(&player)
        update_weapons(&player.weapon_data, &enemies)
        update_enemies(&enemies)

        next_enemy_timer -= 1;
        if next_enemy_timer <= 0 {
            create_enemy(&enemies)
            next_enemy_timer = rand.int_range(50, 120);
        }

        rl.BeginDrawing()
            rl.ClearBackground(rl.LIGHTGRAY)
            
            draw_player(&player)
            draw_bullets(&player.weapon_data.bullets)
            draw_enemies(&enemies)

            rl.DrawRectangle(0, 0, 150, 60, rl.Color{40, 40, 40, 170})
            draw_formatted_label("FPS: %d", 0, 0, 20, rl.WHITE, rl.GetFPS())
            draw_formatted_label("Bullets: %d", 0, 20, 20, rl.WHITE, len(&player.weapon_data.bullets))
            draw_formatted_label("Enemies: %d", 0, 40, 20, rl.WHITE, len(enemies))
        
        rl.EndDrawing()
    }
}