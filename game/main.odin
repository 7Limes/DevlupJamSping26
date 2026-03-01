package game

import "core:fmt"
import "core:math/rand"
import "core:math"
import "core:strings"
import rl "vendor:raylib"
import "../particle"
import "core:mem"

WIN_WIDTH :: 1200
WIN_HEIGHT :: 800

CENTER :: rl.Vector2{WIN_WIDTH/2, WIN_HEIGHT/2}

FIELD_RECT :: rl.Rectangle{200, 0, 800, 800}

PLAYER_RADIUS :: 30
PLAYER_MAX_HEALTH :: 100
PLAYER_SHOOT_DISTANCE :: 100
SHOOT_SPEED :: 5.0
PLAYER_COLOR :: rl.Color{50, 50, 220, 255}
PLAYER_OUTLINE_COLOR :: rl.Color{30, 30, 170, 255}
SHIELD_START_COLOR :: rl.Color{150, 230, 247, 255}
SHIELD_END_COLOR :: rl.Color{121, 188, 247, 255}

HIGH_HEALTH_COLOR :: rl.LIME
LOW_HEALTH_COLOR :: rl.RED

AMMO_LABEL_Y :: 450
HEALTH_LABEL_Y :: 325


GameState :: enum {
    Title,
    Game,
    Dead
}


Player :: struct {
    facing_vector: rl.Vector2,
    weapon_data: WeaponData
}

// Maps
WEAPON_TOOLTIPS: map[WeaponType][2]cstring
ENEMY_MONEY_MAP: map[EnemyType]int


// Globals
global_effects: particle.SystemGroup
global_enemies: #soa[dynamic]Enemy

global_money: int = 10000
global_health: f32 = PLAYER_MAX_HEALTH

global_wave_data: WaveData

global_dog_sprite := TEX_DOG_SUSPICIOUS

global_state := GameState.Title

global_saved_framebuffer: rl.Texture2D

global_debug_enabled := false
global_listening_for_cheat := false



is_shooting :: proc() -> bool {
    return (rl.IsKeyDown(.RIGHT_SHIFT) || rl.IsKeyDown(.LEFT_SHIFT) || rl.IsMouseButtonDown(.LEFT)) &&
            rl.CheckCollisionPointRec(rl.GetMousePosition(), FIELD_RECT) &&
            (tutorial_index >= len(TUTORIAL_DATA))
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
    rl.DrawTextureEx(global_dog_sprite, CENTER-{45,50}, 0, 0.2, rl.WHITE)
    // rl.DrawCircle(i32(CENTER.x), i32(CENTER.y), PLAYER_RADIUS+5, PLAYER_OUTLINE_COLOR)
    // rl.DrawCircle(i32(CENTER.x), i32(CENTER.y), PLAYER_RADIUS, PLAYER_COLOR)

    facing_angle := math.atan2_f32(player.facing_vector.y, player.facing_vector.x) * math.DEG_PER_RAD
    weapon_tex := WEAPON_TEXTURES[player.weapon_data.current]
    source := rl.Rectangle{0, 0, f32(weapon_tex.width), f32(weapon_tex.height)};
    dest := rl.Rectangle{CENTER.x, CENTER.y, source.width*1.5, source.height*1.5}
    origin := rl.Vector2{source.width-75, source.height-5} / 2 * 1.5
    rl.DrawTexturePro(weapon_tex, source, dest, origin, facing_angle, rl.WHITE)
}


draw_ammo_label :: proc(player: ^Player) {
    rl.DrawTextureEx(TEX_ICON_BULLET, {CENTER.x-35, AMMO_LABEL_Y-7}, 0, 2.0, rl.WHITE)
    draw_formatted_label("%d", i32(CENTER.x+5), AMMO_LABEL_Y, 20, rl.BLACK, player.weapon_data.ammo)
}

draw_health_label :: proc() {
    rl.DrawTextureEx(TEX_ICON_HEART, {CENTER.x-35, HEALTH_LABEL_Y}, 0, 2.0, rl.WHITE)
    draw_formatted_label("%.1f", i32(CENTER.x+5), HEALTH_LABEL_Y+5, 20, rl.BLACK, global_health)
}

draw_money_label :: proc() {
    rl.DrawTextureEx(TEX_ICON_MONEY, {1000, 30}, 0, 3.0, rl.WHITE)
    money_string := format_with_commas(global_money)
    rl.DrawText(strings.clone_to_cstring(money_string, context.temp_allocator), 1050, 45, 30, rl.BLACK)
}


create_player_shield :: proc() {
    effect := particle.create_system()
    effect.position = CENTER
    effect.particle_sprite = TEX_SHIELD_PARTICLE
    effect.emitting = true
    effect.emission_interval = 0.02
    effect.emission_shape = .Ring
    effect.spread = {100, 2}  // Radius of 100 with a variance of 5
    effect.emission_angle_var = 2 * math.PI
    effect.start_color = rl.ColorAlpha(SHIELD_START_COLOR, 0.8)
    effect.end_color = rl.ColorAlpha(SHIELD_END_COLOR, 0.0)
    effect.random_start_angle = true
    effect.duration = 180
    effect.duration_var = 30
    effect.angular_velocity_var = 5
    effect.start_size = 0.05
    effect.end_size = 0.05
    particle.add_to_system_group(&global_effects, effect)

    effect2 := particle.create_system()
    effect2.position = CENTER
    effect2.particle_sprite = TEX_IMPACT_PARTICLE
    effect2.emitting = true
    effect2.emission_interval = 1.0
    effect2.emission_angle_var = 2 * math.PI
    effect2.start_color = rl.ColorAlpha(SHIELD_START_COLOR, 0.8)
    effect2.end_color = rl.ColorAlpha(SHIELD_END_COLOR, 0.0)
    effect2.random_start_angle = true
    effect2.duration = 120
    effect2.start_size = 0.01
    effect2.end_size = 0.5
    particle.populate_system(&effect2, 1)
    particle.add_to_system_group(&global_effects, effect2)
}

toggle_debug :: proc() {
    if rl.IsKeyPressed(.GRAVE) {
        global_debug_enabled = !global_debug_enabled
    }
}

cheats_tick :: proc(weapon_data: ^WeaponData) {
    if !global_debug_enabled {
        return
    }

    if rl.IsKeyPressed(.SLASH) {
        global_listening_for_cheat = !global_listening_for_cheat
    }

    if global_listening_for_cheat {
        rl.DrawText("listening", 130, 705, 16, rl.BLACK)
        if rl.IsKeyPressed(.G) {
            global_money += 10000
            global_listening_for_cheat = false
        }
        else if rl.IsKeyPressed(.N) {
            next_wave(&global_wave_data)
            global_listening_for_cheat = false
        }
        else if rl.IsKeyPressed(.R) {
            change_weapon(weapon_data, weapon_data.current)
            global_listening_for_cheat = false
        }
    }

}


draw_formatted_label :: proc(fstring: string, x, y, font_size: i32, color: rl.Color, args: ..any) {
    str := format_as_cstring(fstring, ..args)
    rl.DrawText(str, x, y, font_size, color)
}


title_update :: proc(player: ^Player) {
    rl.BeginDrawing()
    rl.DrawTextureEx(TEX_TITLE_BACKGROUND, {0, 0}, 0, 6, rl.WHITE)

    logo_y := f32(math.sin(rl.GetTime() * 1.5) * 15)
    rl.DrawTextureEx(TEX_LOGO, {350, 50+logo_y}, 0, 1, rl.WHITE)

    saved_text_size := rl.GuiGetStyle(.DEFAULT, 16)
    rl.GuiSetStyle(.DEFAULT, 16, 40)
    if rl.GuiButton({500, 500, 200, 100}, "Begin") {
        init_game(player)
        global_state = .Game
    }

    rl.GuiSetStyle(.DEFAULT, 16, saved_text_size)

    rl.EndDrawing()
}


game_update :: proc(player: ^Player) {
    if global_health <= 0 {
        screen := rl.LoadImageFromScreen()
        global_saved_framebuffer := rl.LoadTextureFromImage(screen)
        rl.UnloadImage(screen)
        global_state = .Dead
    }

    delta := rl.GetFrameTime()

    update_player(player)
    update_weapons(&player.weapon_data)
    if !is_shooting() {
        rl.StopMusicStream(SOUND_LASER_LOOP)
    }
    update_enemies(&global_enemies)

    wave_update(&global_wave_data, delta)

    update_weapon_conveyor(delta)

    rl.BeginDrawing()
        rl.DrawTextureEx(TEX_BACKGROUND, {200, 0}, 0, 2.0, rl.WHITE)
        
        draw_player(player)
        draw_enemies(&global_enemies)
        draw_weapons(player)

        particle.update_system_group(&global_effects, delta)
        particle.draw_system_group(&global_effects)
        
        draw_animated_wave_label(&global_wave_data)
        show_weapon_conveyor_ui(&player.weapon_data)
        show_weapon_upgrade_ui(&player.weapon_data)
        draw_wave_label(&global_wave_data)

        draw_ammo_label(player)
        draw_health_label()
        draw_money_label()
        

        show_tutorial()

        if global_debug_enabled {
            rl.GuiPanel({0, 700, 200, 100}, "debug")
            draw_formatted_label("FPS: %d", 0, 730, 20, rl.BLACK, rl.GetFPS())
            draw_formatted_label("Bullets: %d", 0, 750, 20, rl.BLACK, len(&player.weapon_data.bullets))
            draw_formatted_label("Enemies: %d", 0, 770, 20, rl.BLACK, len(global_enemies))
        }
        cheats_tick(&player.weapon_data)

        
    rl.EndDrawing()
}

dead_update :: proc() {
    rl.BeginDrawing()
    
    rl.DrawTexture(global_saved_framebuffer, 0, 0, rl.WHITE)
    rl.GuiPanel({400, 300, 400, 200}, "Game Over")
    if rl.GuiButton({500, 350, 200, 100}, "Back to Title") {
        rl.UnloadTexture(global_saved_framebuffer)
        global_state = .Title
    }

    rl.EndDrawing()
}

init_game :: proc(player: ^Player) {
    reset_weapon_data(&player.weapon_data)

    particle.clear_system_group(&global_effects)
    clear_soa_dynamic_array(&global_enemies)
    clear_dynamic_array(&conveyor_contents)

    global_money = 0
    global_health = PLAYER_MAX_HEALTH
    init_wave_data(&global_wave_data)
    global_dog_sprite = TEX_DOG_SUSPICIOUS
    global_box_spawn_timer = 0

    create_player_shield()
    change_weapon(&player.weapon_data, .MachineGun)
}

load_style :: proc(style_path: string) {
    path := format_as_cstring("%s%s", rl.GetApplicationDirectory(), style_path)
    rl.GuiLoadStyle(path)
}

main :: proc() {
    when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

    WEAPON_TOOLTIPS[.MachineGun] = {"Machine Gun", "Rapidly fires bullets"}
    WEAPON_TOOLTIPS[.Cannon] = {"Cannon", "Fires an explosive projectile"}
    WEAPON_TOOLTIPS[.Shotgun] = {"Shotgun", "Fires a spread of multiple bullets"}
    WEAPON_TOOLTIPS[.Laser] = {"Laser", "Shoots a continuous laser"}

    ENEMY_MONEY_MAP[.Normal] = 5
    ENEMY_MONEY_MAP[.Big] = 10

    player := Player{rl.Vector2{0, -1}, create_weapon_data()}
    defer delete_weapon_data(&player.weapon_data)

    defer delete_soa(global_enemies)

    global_effects = particle.create_system_group(0.5)
    defer particle.delete_system_group(&global_effects)
    
    rl.SetConfigFlags(rl.ConfigFlags{rl.ConfigFlag.MSAA_4X_HINT})
    rl.InitWindow(WIN_WIDTH, WIN_HEIGHT, "C.H.A.D")
    rl.SetTargetFPS(60)
    rl.SetExitKey(.KEY_NULL)
    load_style("assets/style/style_candy.rgs")

    load_textures()
    load_audio()

    for !rl.WindowShouldClose() {
        toggle_debug()
        switch global_state {
            case .Title:
                title_update(&player)
            case .Game:
                game_update(&player)
            case .Dead:
                dead_update()

        }

        free_all(context.temp_allocator)
    }

    rl.CloseWindow()
}