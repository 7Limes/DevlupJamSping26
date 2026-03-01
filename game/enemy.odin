package game

import "core:math"
import "core:math/rand"
import rl "vendor:raylib"
import "../particle"
import "core:fmt"

EnemyType :: enum {
    Normal,
    Big,
    Huge
}


Enemy :: struct {
    type: EnemyType,
    position: rl.Vector2,
    radius: f32,
    max_health, health: f32,
    speed: f32,
    damage: f32,
    slowdown_timer: int,
    sprite: rl.Texture2D
}


NORMAL_ENEMY_RADIUS :: 15
NORMAL_ENEMY_SPEED :: 0.6
NORMAL_ENEMY_HEALTH :: 5
NORMAL_ENEMY_DAMAGE :: 0.01

BIG_ENEMY_RADIUS :: 25
BIG_ENEMY_SPEED :: 0.3
BIG_ENEMY_HEALTH :: 10
BIG_ENEMY_DAMAGE :: 0.02

HUGE_ENEMY_RADIUS :: 50
HUGE_ENEMY_SPEED :: 0.2
HUGE_ENEMY_HEALTH :: 30
HUGE_ENEMY_DAMAGE :: 0.1

ENEMY_SLOWDOWN_TIME :: 15

ENEMY_HEALTHBAR_WIDTH :: 50
ENEMY_HEALTHBAR_HEIGHT :: 10


update_enemies :: proc(enemies: ^#soa[dynamic]Enemy) {
    for i := 0; i < len(enemies); i+=1 {
        enemy := &enemies[i]
        
        if enemy.health <= 0 {
            create_enemy_death_effect(enemy.position, enemy.radius)
            global_money += ENEMY_MONEY_MAP[enemy.type]
            unordered_remove_soa(enemies, i)
            i -= 1
            continue
        }

        if rl.Vector2Distance(enemy.position, CENTER) > PLAYER_RADIUS * 2 + 50 {
            speed := enemy.speed if enemy.slowdown_timer == 0 else enemy.speed/2
            move_vector := rl.Vector2Normalize(CENTER - enemy.position) * speed
            enemy.position += move_vector
        }
        else {
            global_health -= enemy.damage
        }

        if enemy.slowdown_timer > 0 {
            enemy.slowdown_timer -= 1
        }
    }
}


get_enemy_spawn_point :: proc() -> rl.Vector2 {
    angle := rand.float32_range(0, 2 * math.PI)
    return rl.Vector2Rotate(rl.Vector2{0, -1}, angle) * (FIELD_RECT.width / 2 * 1.41) + CENTER
}


create_normal_enemy :: proc(enemies: ^#soa[dynamic]Enemy) {
    enemy_pos := get_enemy_spawn_point()
    enemy := Enemy{.Normal, enemy_pos, NORMAL_ENEMY_RADIUS, NORMAL_ENEMY_HEALTH, NORMAL_ENEMY_HEALTH, NORMAL_ENEMY_SPEED, NORMAL_ENEMY_DAMAGE, 0, TEX_NORMAL_ENEMY}
    append(enemies, enemy)
}

create_big_enemy :: proc(enemies: ^#soa[dynamic]Enemy) {
    enemy_pos := get_enemy_spawn_point()
    enemy := Enemy{.Big, enemy_pos, BIG_ENEMY_RADIUS, BIG_ENEMY_HEALTH, BIG_ENEMY_HEALTH, BIG_ENEMY_SPEED, BIG_ENEMY_DAMAGE, 0, TEX_BIG_ENEMY}
    append(enemies, enemy)
}

create_huge_enemy :: proc(enemies: ^#soa[dynamic]Enemy) {
    enemy_pos := get_enemy_spawn_point()
    enemy := Enemy{.Huge, enemy_pos, HUGE_ENEMY_RADIUS, HUGE_ENEMY_HEALTH, HUGE_ENEMY_HEALTH, HUGE_ENEMY_SPEED, HUGE_ENEMY_DAMAGE, 0, TEX_HUGE_ENEMY}
    append(enemies, enemy)
}


draw_enemies :: proc(enemies: ^#soa[dynamic]Enemy) {
    for enemy in enemies {
        rl.DrawTextureEx(enemy.sprite, enemy.position-{enemy.radius, enemy.radius}, 0, enemy.radius*2/f32(enemy.sprite.width), rl.WHITE)

        // Draw healthbar
        if enemy.health < enemy.max_health {
            healthbar_pos := rl.Vector2{enemy.position.x-ENEMY_HEALTHBAR_WIDTH/2, enemy.position.y-enemy.radius-15}
            health_t := f32(enemy.health) / enemy.max_health
            filled_health_width := health_t * ENEMY_HEALTHBAR_WIDTH
            filled_health_color := rl.ColorLerp(LOW_HEALTH_COLOR, HIGH_HEALTH_COLOR, health_t)
            rl.DrawRectangle(i32(healthbar_pos.x), i32(healthbar_pos.y), ENEMY_HEALTHBAR_WIDTH, ENEMY_HEALTHBAR_HEIGHT, rl.Color{50, 50, 50, 128})
            rl.DrawRectangle(i32(healthbar_pos.x), i32(healthbar_pos.y), i32(filled_health_width), ENEMY_HEALTHBAR_HEIGHT, filled_health_color)
            rl.DrawRectangleLinesEx(rl.Rectangle{healthbar_pos.x-1, healthbar_pos.y-1, ENEMY_HEALTHBAR_WIDTH+2, ENEMY_HEALTHBAR_HEIGHT+2}, 2, rl.BLACK)
        }
    }
}

create_enemy_death_effect :: proc(position: rl.Vector2, radius: f32) {
    effect := particle.create_system()
    effect.position = position
    effect.particle_sprite = TEX_SMOKE_PARTICLE
    effect.emission_strength = 0.1 * radius
    effect.emission_strength_var = 5
    effect.emission_angle_var = 2 * math.PI
    effect.drag = 0.5
    effect.start_color = rl.ColorAlpha(rl.WHITE, 0.8)
    effect.end_color = rl.ColorAlpha(rl.WHITE, 0.0)
    effect.random_start_angle = true
    effect.duration = 80
    effect.duration_var = 15
    effect.angular_velocity_var = 3
    effect.start_size = 0.1
    effect.end_size = 0.0
    particle.populate_system(&effect, int(0.2 * radius))
    particle.add_to_system_group(&global_effects, effect)
}