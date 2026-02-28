package game

import "core:math"
import "core:math/rand"
import rl "vendor:raylib"


Enemy :: struct {
    position: rl.Vector2,
    radius: f32,
    health: f32,
    speed: f32,
    slowdown_timer: int
}

ENEMY_SPEED :: 0.5
ENEMY_SLOWDOWN_TIME :: 15
ENEMY_MAX_HEALTH :: 10
ENEMY_COLOR :: rl.Color{220, 50, 50, 255}
ENEMY_OUTLINE_COLOR :: rl.Color{170, 30, 30, 255}
ENEMY_HEALTHBAR_WIDTH :: 50
ENEMY_HEALTHBAR_HEIGHT :: 10


update_enemies :: proc(enemies: ^#soa[dynamic]Enemy) {
    for i := 0; i < len(enemies); i+=1 {
        enemy := &enemies[i]
        
        if enemy.health <= 0 {
            unordered_remove_soa(enemies, i)
            i -= 1
            continue
        }

        if rl.Vector2Distance(enemy.position, CENTER) > PLAYER_RADIUS * 2 {
            speed := enemy.speed if enemy.slowdown_timer == 0 else enemy.speed/2
            move_vector := rl.Vector2Normalize(CENTER - enemy.position) * speed
            enemy.position += move_vector
        }

        if enemy.slowdown_timer > 0 {
            enemy.slowdown_timer -= 1
        }
    }
}


create_enemy :: proc(enemies: ^#soa[dynamic]Enemy) {
    angle := rand.float32_range(0, 2 * math.PI)
    enemy_pos := rl.Vector2Rotate(rl.Vector2{0, -1}, angle) * (WIN_WIDTH / 2 * 1.41) + CENTER
    enemy_speed := rand.float32_range(ENEMY_SPEED-0.5, ENEMY_SPEED+0.5)
    enemy := Enemy{enemy_pos, 10, ENEMY_MAX_HEALTH, enemy_speed, 0}
    append(enemies, enemy)
}


draw_enemies :: proc(enemies: ^#soa[dynamic]Enemy) {
    for enemy in enemies {
        rl.DrawCircle(i32(enemy.position.x), i32(enemy.position.y), enemy.radius+4, ENEMY_OUTLINE_COLOR)
        rl.DrawCircle(i32(enemy.position.x), i32(enemy.position.y), enemy.radius, ENEMY_COLOR)

        // Draw healthbar
        healthbar_pos := rl.Vector2{enemy.position.x-ENEMY_HEALTHBAR_WIDTH/2, enemy.position.y-enemy.radius-15}
        health_t := f32(enemy.health) / ENEMY_MAX_HEALTH
        filled_health_width := health_t * ENEMY_HEALTHBAR_WIDTH
        filled_health_color := rl.ColorLerp(LOW_HEALTH_COLOR, HIGH_HEALTH_COLOR, health_t)
        rl.DrawRectangle(i32(healthbar_pos.x), i32(healthbar_pos.y), ENEMY_HEALTHBAR_WIDTH, ENEMY_HEALTHBAR_HEIGHT, rl.Color{50, 50, 50, 128})
        rl.DrawRectangle(i32(healthbar_pos.x), i32(healthbar_pos.y), i32(filled_health_width), ENEMY_HEALTHBAR_HEIGHT, filled_health_color)
        rl.DrawRectangleLinesEx(rl.Rectangle{healthbar_pos.x-2, healthbar_pos.y-2, ENEMY_HEALTHBAR_WIDTH+4, ENEMY_HEALTHBAR_HEIGHT+4}, 3, rl.BLACK)
    }
}