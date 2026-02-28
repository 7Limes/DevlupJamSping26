package game

import "core:fmt"
import "core:math/rand"
import "core:math"
import "core:strings"
import rl "vendor:raylib"
import "../particle"

WIN_WIDTH :: 1200
WIN_HEIGHT :: 800

CENTER :: rl.Vector2{WIN_WIDTH/2, WIN_HEIGHT/2}

FIELD_RECT :: rl.Rectangle{200, 0, 800, 800}

PLAYER_RADIUS :: 30
PLAYER_TURN_SPEED :: 0.08
PLAYER_SHOOT_DISTANCE :: 100
SHOOT_SPEED :: 5.0
PLAYER_COLOR :: rl.Color{50, 50, 220, 255}
PLAYER_OUTLINE_COLOR :: rl.Color{30, 30, 170, 255}

HIGH_HEALTH_COLOR :: rl.LIME
LOW_HEALTH_COLOR :: rl.RED

AMMO_LABEL_Y :: 450


WEAPON_TOOLTIPS: map[WeaponType][2]cstring

Player :: struct {
    facing_vector: rl.Vector2,
    weapon_data: WeaponData
}

global_effects: particle.SystemGroup


is_shooting :: proc() -> bool {
    return (rl.IsKeyDown(.RIGHT_SHIFT) || rl.IsKeyDown(.LEFT_SHIFT) || rl.IsMouseButtonDown(.LEFT)) &&
            rl.CheckCollisionPointRec(rl.GetMousePosition(), FIELD_RECT)
}


// Update procedures
update_player :: proc(player: ^Player) {
    player.facing_vector = rl.Vector2Normalize(rl.GetMousePosition() - CENTER)

    // Handle firing
    if is_shooting() {
        shoot_point := CENTER + player.facing_vector * PLAYER_SHOOT_DISTANCE
        shot := shoot_weapon(&player.weapon_data, shoot_point, player.facing_vector)
    }
}


// Drawing procedures
draw_player :: proc(player: ^Player) {
    rl.DrawCircle(i32(CENTER.x), i32(CENTER.y), PLAYER_RADIUS+5, PLAYER_OUTLINE_COLOR)
    rl.DrawCircle(i32(CENTER.x), i32(CENTER.y), PLAYER_RADIUS, PLAYER_COLOR)

    weapon_tex := WEAPON_TEXTURES[player.weapon_data.current]
    facing_angle := math.atan2_f32(player.facing_vector.y, player.facing_vector.x) * math.DEG_PER_RAD
    source := rl.Rectangle{0, 0, f32(weapon_tex.width), f32(weapon_tex.height)};
    dest := rl.Rectangle{CENTER.x, CENTER.y, source.width*1.5, source.height*1.5}
    origin := rl.Vector2{source.width-75, source.height} / 2 * 1.5
    rl.DrawTexturePro(weapon_tex, source, dest, origin, facing_angle, rl.WHITE)
}


draw_ammo_label :: proc(player: ^Player) {
    rl.DrawTextureEx(TEX_ICON_BULLET, {CENTER.x-35, AMMO_LABEL_Y-7}, 0, 2.0, rl.WHITE)
    draw_formatted_label("%d", i32(CENTER.x+5), AMMO_LABEL_Y, 20, rl.BLACK, player.weapon_data.ammo)
}


draw_formatted_label :: proc(fstring: string, x, y, font_size: i32, color: rl.Color, args: ..any) {
    builder := strings.builder_make()
    formatted_string := fmt.sbprintf(&builder, fstring, ..args)
    formatted_cstring := strings.clone_to_cstring(formatted_string)
    rl.DrawText(formatted_cstring, x, y, font_size, color)
    strings.builder_destroy(&builder)
}

main :: proc() {
    WEAPON_TOOLTIPS[.MachineGun] = {"Machine Gun", "Rapidly fires bullets"}
    WEAPON_TOOLTIPS[.Cannon] = {"Cannon", "Fires an explosive projectile"}
    WEAPON_TOOLTIPS[.Shotgun] = {"Shotgun", "Fires a spread of multiple bullets"}
    WEAPON_TOOLTIPS[.Laser] = {"Laser", "Shoots a continuous laser"}

    player := Player{rl.Vector2{0, -1}, create_weapon_data()}
    defer delete_weapon_data(&player.weapon_data)

    enemies: #soa[dynamic]Enemy
    defer delete_soa(enemies)

    global_effects = particle.create_system_group(0.5)
    defer particle.delete_system_group(&global_effects)
    
    rl.SetConfigFlags(rl.ConfigFlags{rl.ConfigFlag.MSAA_4X_HINT})
    rl.InitWindow(WIN_WIDTH, WIN_HEIGHT, "window title")
    rl.SetTargetFPS(60)
    rl.GuiLoadStyle("assets/style/style_candy.rgs")

    load_textures()


    next_enemy_timer := 90

    for !rl.WindowShouldClose() {
        update_player(&player)
        update_weapons(&player.weapon_data, &enemies)
        update_enemies(&enemies)

        update_weapon_conveyor(rl.GetFrameTime())

        next_enemy_timer -= 1;
        if next_enemy_timer <= 0 {
            create_enemy(&enemies)
            next_enemy_timer = rand.int_range(50, 120);
        }

        rl.BeginDrawing()
            rl.ClearBackground(rl.LIGHTGRAY)
            
            draw_player(&player)
            draw_enemies(&enemies)
            draw_weapons(&player)
            particle.update_system_group(&global_effects, rl.GetFrameTime())
            particle.draw_system_group(&global_effects)

            show_weapon_conveyor_ui(&player.weapon_data)
            show_weapon_upgrade_ui()

            draw_ammo_label(&player)

            rl.DrawRectangle(700, 375, 200, 50, rl.Color{0, 0, 0, 100})

            rl.GuiPanel({0, 700, 200, 100}, "debug")
            draw_formatted_label("FPS: %d", 0, 730, 20, rl.BLACK, rl.GetFPS())
            draw_formatted_label("Bullets: %d", 0, 750, 20, rl.BLACK, len(&player.weapon_data.bullets))
            draw_formatted_label("Enemies: %d", 0, 770, 20, rl.BLACK, len(enemies))
        
        rl.EndDrawing()
    }

    rl.CloseWindow()
}