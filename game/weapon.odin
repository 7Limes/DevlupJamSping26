package game

import rl "vendor:raylib"
import "core:fmt"
import "core:math"
import "../particle"

MG_BASE_AMMO :: 100
MG_BASE_FIRE_INTERVAL :: 10
MG_BASE_DAMAGE :: 1
MG_BULLET_SPEED :: 5.0

CANNON_BASE_AMMO :: 10
CANNON_BASE_RADIUS :: 60
CANNON_BASE_DAMAGE :: 10
CANNON_FIRE_INTERVAL :: 50
CB_SPEED :: 4.0
CB_VISUAL_RADIUS :: 10

SHOTGUN_BASE_AMMO :: 30
SHOTGUN_BASE_FIRE_INTERVAL :: 20
SHOTGUN_BASE_DAMAGE :: 3
SHOTGUN_SPREAD :: 0.5
SHOTGUN_BULLET_SPEED :: 7.5

LASER_BASE_AMMO :: 300
LASER_BASE_DAMAGE :: 0.25
LASER_BASE_BEAM_WIDTH :: 50

BULLET_RADIUS :: 5
BULLET_COLOR :: rl.Color{220, 220, 50, 255}
BULLET_OUTLINE_COLOR :: rl.Color{120, 120, 20, 255}


Bullet :: struct {
    position, velocity: rl.Vector2,
    damage: f32,
    pierces: int
}

CannonBall :: struct {
    position, target_position: rl.Vector2,
    damage: f32,
    damage_radius: f32
}


MachineGun :: struct {
    max_ammo: int,
    fire_interval: int,
    damage: f32,
    twin: bool
}

Cannon :: struct {
    max_ammo: int,
    radius: f32,
    damage: f32
}

Shotgun :: struct {
    max_ammo: int,
    fire_interval: int,
    damage: f32,
    barrels: int
}

Laser :: struct {
    max_ammo: int,
    damage: f32,
    beam_width: f32
}

Sniper :: struct {

}

WeaponType :: enum {
    MachineGun,
    Cannon,
    Shotgun,
    Laser
}

WeaponData :: struct {
    current: WeaponType,
    ammo, fire_cooldown: int,
    bullets: #soa[dynamic]Bullet,
    cannonballs: #soa[dynamic]CannonBall,

    machine_gun: MachineGun,
    cannon: Cannon,
    shotgun: Shotgun,
    laser: Laser
}

create_weapon_data :: proc() -> WeaponData {
    bullets: #soa[dynamic]Bullet
    cannonballs: #soa[dynamic]CannonBall

    return {
        .Laser, LASER_BASE_AMMO, 0,
        bullets, cannonballs,
        MachineGun{MG_BASE_AMMO, MG_BASE_FIRE_INTERVAL, MG_BASE_DAMAGE, false},
        Cannon{CANNON_BASE_AMMO, CANNON_BASE_RADIUS, CANNON_BASE_DAMAGE},
        Shotgun{SHOTGUN_BASE_AMMO, SHOTGUN_BASE_FIRE_INTERVAL, SHOTGUN_BASE_DAMAGE, 3},
        Laser{LASER_BASE_AMMO, LASER_BASE_DAMAGE, LASER_BASE_BEAM_WIDTH}
    }
}

delete_weapon_data :: proc(weapon_data: ^WeaponData) {
    delete_soa(weapon_data.bullets)
    delete_soa(weapon_data.cannonballs)
}


shoot_weapon :: proc(weapon_data: ^WeaponData, shoot_point, facing_vector: rl.Vector2) -> bool {
    if weapon_data.ammo <= 0 || weapon_data.fire_cooldown > 0 {
        return false
    }

    switch (weapon_data.current) {
        case .MachineGun:
            shoot_machine_gun(weapon_data, shoot_point, facing_vector)
        case .Cannon:
            shoot_cannon(weapon_data, shoot_point, facing_vector)
        case .Shotgun:
            shoot_shotgun(weapon_data, shoot_point, facing_vector)
        case .Laser:
            shoot_laser(weapon_data, shoot_point, facing_vector)
    }

    return true
}


shoot_machine_gun :: proc(weapon_data: ^WeaponData, shoot_point, facing_vector: rl.Vector2) {
    machine_gun := &weapon_data.machine_gun
    bullet := Bullet{shoot_point, facing_vector * MG_BULLET_SPEED, machine_gun.damage, 1}
    weapon_data.fire_cooldown = machine_gun.fire_interval
    weapon_data.ammo -= 1
    append_soa(&weapon_data.bullets, bullet)
}

shoot_cannon :: proc(weapon_data: ^WeaponData, shoot_point, facing_vector: rl.Vector2) {
    cannon := &weapon_data.cannon
    cannonball := CannonBall{shoot_point, rl.GetMousePosition(), cannon.damage, cannon.radius}
    weapon_data.fire_cooldown = CANNON_FIRE_INTERVAL
    weapon_data.ammo -= 1
    append_soa(&weapon_data.cannonballs, cannonball)
}

shoot_shotgun :: proc(weapon_data: ^WeaponData, shoot_point, facing_vector: rl.Vector2) {
    shotgun := weapon_data.shotgun
    weapon_data.fire_cooldown = shotgun.fire_interval
    weapon_data.ammo -= 1
    for i := 0; i < shotgun.barrels; i+=1 {
        angle := rl.Lerp(-SHOTGUN_SPREAD, SHOTGUN_SPREAD, f32(i) / f32(shotgun.barrels-1))
        velocity := rl.Vector2Rotate(facing_vector, angle) * SHOTGUN_BULLET_SPEED
        append_soa(&weapon_data.bullets, Bullet{
            shoot_point, velocity, shotgun.damage, 1
        })
    }
}

shoot_laser :: proc(weapon_data: ^WeaponData, shoot_point, facing_vector: rl.Vector2) {
    laser := weapon_data.laser
    weapon_data.fire_cooldown = 0
    weapon_data.ammo -= 1
}


update_weapons :: proc(weapon_data: ^WeaponData, enemies: ^#soa[dynamic]Enemy) {
    if weapon_data.fire_cooldown > 0 {
        weapon_data.fire_cooldown -= 1
    }

    update_bullets(&weapon_data.bullets, enemies)
    update_cannonballs(&weapon_data.cannonballs, enemies)
}


change_weapon :: proc(weapon_data: ^WeaponData, type: WeaponType) {
    weapon_data.current = type
    switch type {
        case .MachineGun:
            weapon_data.ammo = weapon_data.machine_gun.max_ammo
        case .Cannon:
            weapon_data.ammo = weapon_data.cannon.max_ammo
        case .Shotgun:
            weapon_data.ammo = weapon_data.shotgun.max_ammo
        case .Laser:
            weapon_data.ammo = weapon_data.laser.max_ammo
    }
}


is_outside_screen :: proc(position: rl.Vector2) -> bool {
    return position.x < 0 || position.x >= WIN_WIDTH || 
            position.y < 0 || position.y >= WIN_HEIGHT
}


update_bullets :: proc(bullets: ^#soa[dynamic]Bullet, enemies: ^#soa[dynamic]Enemy) {
    for i := 0; i < len(bullets); i+=1 {
        bullet := &bullets[i]
        bullet.position += bullet.velocity
        if is_outside_screen(bullet.position) {
            unordered_remove_soa(bullets, i)
            i -= 1
            continue
        }

        damaged := try_damage_enemies(bullet.position, BULLET_RADIUS, bullet.damage, true, enemies)
        if damaged {
            bullet.pierces -= 1
        }
        if bullet.pierces <= 0 {
            unordered_remove_soa(bullets, i)
            i -= 1
        }
    }
}


update_cannonballs :: proc(cannonballs: ^#soa[dynamic]CannonBall, enemies: ^#soa[dynamic]Enemy) {
    for i := 0; i < len(cannonballs); i+=1 {
        ball := &cannonballs[i]
        ball.position = rl.Vector2MoveTowards(ball.position, ball.target_position, CB_SPEED)

        if rl.Vector2Equals(ball.position, ball.target_position) {
            try_damage_enemies(ball.position, ball.damage_radius, ball.damage, false, enemies)
            
            effect := particle.create_system()
            effect.position = ball.position
            effect.particle_sprite = TEX_FIRE_PARTICLE
            effect.emission_strength = 7
            effect.emission_strength_var = 5
            effect.emission_angle_var = 2 * math.PI
            effect.drag = 0.7
            effect.start_color = rl.ColorAlpha(rl.RED, 0.8)
            effect.end_color = rl.ColorAlpha(rl.YELLOW, 0.0)
            effect.random_start_angle = true
            effect.duration = 80
            effect.duration_var = 15
            effect.angular_velocity_var = 3
            effect.start_size = 0.3
            effect.end_size = 0.0
            particle.populate_system(&effect, 20)

            flare_effect := particle.create_system()
            flare_effect.position = ball.position
            flare_effect.particle_sprite = TEX_FLARE_PARTICLE
            flare_effect.start_color = rl.ColorAlpha(rl.WHITE, 0.6)
            flare_effect.end_color = rl.ColorAlpha(rl.WHITE, 0.0)
            flare_effect.random_start_angle = true
            flare_effect.duration = 10
            flare_effect.duration_var = 2
            flare_effect.angular_velocity_var = 3
            flare_effect.start_size = 0.3
            flare_effect.end_size = 0.5
            particle.populate_system(&flare_effect, 1)

            particle.add_to_system_group(&global_effects, effect)
            particle.add_to_system_group(&global_effects, flare_effect)

            unordered_remove_soa(cannonballs, i)
            i -= 1
        }
    }
}


try_damage_enemies :: proc(position: rl.Vector2, radius, damage: f32, single_enemy: bool, enemies: ^#soa[dynamic]Enemy) -> bool {
    hit_enemy := false

    for &enemy in enemies {
        if rl.CheckCollisionCircles(enemy.position, enemy.radius, position, radius) {
            hit_enemy = true
            enemy.health -= damage
            enemy.slowdown_timer = ENEMY_SLOWDOWN_TIME
            if single_enemy {
                break
            }
        }

    }

    return hit_enemy
}

draw_weapons :: proc(player: ^Player) {
    draw_bullets(&player.weapon_data.bullets)
    draw_cannonballs(&player.weapon_data.cannonballs)
    if is_shooting() && player.weapon_data.current == .Laser && player.weapon_data.ammo > 0 {
        draw_laser(player)
    }
}

draw_bullets :: proc(bullets: ^#soa[dynamic]Bullet) {
    for bullet in bullets {
        rl.DrawCircle(i32(bullet.position.x), i32(bullet.position.y), BULLET_RADIUS+2, BULLET_OUTLINE_COLOR)
        rl.DrawCircle(i32(bullet.position.x), i32(bullet.position.y), BULLET_RADIUS, BULLET_COLOR)
    }
}

draw_cannonballs :: proc(cannonballs: ^#soa[dynamic]CannonBall) {
    for ball in cannonballs {
        rl.DrawCircle(i32(ball.position.x), i32(ball.position.y), CB_VISUAL_RADIUS+2, BULLET_OUTLINE_COLOR)
        rl.DrawCircle(i32(ball.position.x), i32(ball.position.y), CB_VISUAL_RADIUS, BULLET_COLOR)
    }
}

draw_laser :: proc(player: ^Player) {
    beam_width := player.weapon_data.laser.beam_width
    facing_angle := math.atan2_f32(player.facing_vector.y, player.facing_vector.x) * math.DEG_PER_RAD
    source := rl.Rectangle{0, 0, f32(TEX_LASER_BEAM.width), f32(TEX_LASER_BEAM.height)};
    dest := rl.Rectangle{CENTER.x, CENTER.y, source.width*40, beam_width}
    origin := rl.Vector2{source.width-150, source.height+beam_width/2-7} / 2 * 1.5
    rl.DrawTexturePro(TEX_LASER_BEAM, source, dest, origin, facing_angle, rl.WHITE)
}