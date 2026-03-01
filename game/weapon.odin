package game

import rl "vendor:raylib"
import "core:fmt"
import "core:math"
import "../particle"

MG_BASE_AMMO :: 100
MG_BASE_FIRE_INTERVAL :: 10
MG_BASE_DAMAGE :: 1
MG_BULLET_SPEED :: 10.0

CANNON_BASE_SPEED :: 4.0
CANNON_BASE_RADIUS :: 60
CANNON_BASE_DAMAGE :: 5
CANNON_AMMO :: 10
CANNON_FIRE_INTERVAL :: 50
CB_VISUAL_RADIUS :: 10

SHOTGUN_BASE_AMMO :: 30
SHOTGUN_BASE_DAMAGE :: 3
SHOTGUN_FIRE_INTERVAL :: 25
SHOTGUN_SPREAD :: 0.5
SHOTGUN_BULLET_SPEED :: 7.5

LASER_BASE_AMMO :: 200
LASER_BASE_DAMAGE :: 0.05
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
    speed: f32,
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
    speed: f32,
    radius: f32,
    damage: f32
}

Shotgun :: struct {
    max_ammo: int,
    damage: f32,
    barrels: int
}

Laser :: struct {
    max_ammo: int,
    damage: f32,
    beam_width: f32
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
    data := WeaponData{}
    data.bullets = bullets
    data.cannonballs = cannonballs
    reset_weapon_data(&data)
    return data
}


reset_weapon_data :: proc(weapon_data: ^WeaponData) {
    weapon_data^ = {
        .MachineGun, MG_BASE_AMMO, 0,
        weapon_data.bullets, weapon_data.cannonballs,
        MachineGun{MG_BASE_AMMO, MG_BASE_FIRE_INTERVAL, MG_BASE_DAMAGE, false},
        Cannon{CANNON_BASE_SPEED, CANNON_BASE_RADIUS, CANNON_BASE_DAMAGE},
        Shotgun{SHOTGUN_BASE_AMMO, SHOTGUN_BASE_DAMAGE, 3},
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
    create_muzzle_flash_effect(shoot_point, facing_vector)
    create_shell_effect(shoot_point, facing_vector, TEX_ICON_BULLET)
    rl.PlaySound(SOUND_ASSAULT_SHOT)
}

shoot_cannon :: proc(weapon_data: ^WeaponData, shoot_point, facing_vector: rl.Vector2) {
    cannon := &weapon_data.cannon
    cannonball := CannonBall{shoot_point, rl.GetMousePosition(), cannon.speed, cannon.damage, cannon.radius}
    weapon_data.fire_cooldown = CANNON_FIRE_INTERVAL
    weapon_data.ammo -= 1
    append_soa(&weapon_data.cannonballs, cannonball)
    create_muzzle_flash_effect(shoot_point, facing_vector)
}

shoot_shotgun :: proc(weapon_data: ^WeaponData, shoot_point, facing_vector: rl.Vector2) {
    shotgun := weapon_data.shotgun
    weapon_data.fire_cooldown = SHOTGUN_FIRE_INTERVAL
    weapon_data.ammo -= 1
    for i := 0; i < shotgun.barrels; i+=1 {
        angle := rl.Lerp(-SHOTGUN_SPREAD, SHOTGUN_SPREAD, f32(i) / f32(shotgun.barrels-1))
        velocity := rl.Vector2Rotate(facing_vector, angle) * SHOTGUN_BULLET_SPEED
        append_soa(&weapon_data.bullets, Bullet{
            shoot_point, velocity, shotgun.damage, 1
        })
    }

    create_muzzle_flash_effect(shoot_point, facing_vector)
    create_shell_effect(shoot_point, facing_vector, TEX_SHOTGUN_SHELL_PARTICLE)
    play_aliased_sound(&SHOTGUN_SOUND_POOL)
}

shoot_laser :: proc(weapon_data: ^WeaponData, shoot_point, facing_vector: rl.Vector2) {
    laser := weapon_data.laser
    weapon_data.fire_cooldown = 0
    weapon_data.ammo -= 1
    beam_end := shoot_point + facing_vector * 1000
    for &enemy in global_enemies {
        dist_sq := point_to_segment_distance_sq(enemy.position, shoot_point, beam_end)
        combined_radius := (laser.beam_width / 2) + enemy.radius
        if dist_sq <= combined_radius * combined_radius {
            enemy.health -= laser.damage
        }
    }

    if !rl.IsMusicStreamPlaying(SOUND_LASER_LOOP) {
        rl.PlayMusicStream(SOUND_LASER_LOOP)
    }
    rl.UpdateMusicStream(SOUND_LASER_LOOP)
}


create_muzzle_flash_effect :: proc(shoot_point, facing_vector: rl.Vector2) {
    effect := particle.create_system()
    effect.position = shoot_point + facing_vector * 25
    effect.particle_sprite = TEX_MUZZLE_FLASH_PARTICLE
    effect.angle = math.atan2_f32(facing_vector.y, facing_vector.x) * math.DEG_PER_RAD + 90
    effect.start_color = rl.Color{250, 231, 177, 220}
    effect.end_color = rl.Color{250, 231, 177, 0}
    effect.duration = 10
    effect.start_size = 0.15
    effect.end_size = 0.15
    particle.populate_system(&effect, 1)
    particle.add_to_system_group(&global_effects, effect)
}


create_shell_effect :: proc(shoot_point, facing_vector: rl.Vector2, texture: rl.Texture2D) {
    effect := particle.create_system()
    effect.position = shoot_point + facing_vector * 10
    effect.particle_sprite = texture
    effect.emission_strength = 7
    effect.emission_strength_var = 2
    effect.emission_angle_var = 2 * math.PI
    effect.drag = 0.5
    effect.random_start_angle = true
    effect.angular_velocity_var = 5
    effect.start_color = rl.WHITE
    effect.end_color = rl.ColorAlpha(rl.WHITE, 0)
    effect.duration = 120
    effect.start_size = 1.0
    effect.end_size = 1.0
    particle.populate_system(&effect, 1)
    particle.add_to_system_group(&global_effects, effect)
}


update_weapons :: proc(weapon_data: ^WeaponData) {
    if weapon_data.fire_cooldown > 0 {
        weapon_data.fire_cooldown -= 1
    }

    update_bullets(&weapon_data.bullets)
    update_cannonballs(&weapon_data.cannonballs)
}


change_weapon :: proc(weapon_data: ^WeaponData, type: WeaponType) {
    weapon_data.current = type
    switch type {
        case .MachineGun:
            weapon_data.ammo = weapon_data.machine_gun.max_ammo
        case .Cannon:
            weapon_data.ammo = CANNON_AMMO
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


update_bullets :: proc(bullets: ^#soa[dynamic]Bullet) {
    for i := 0; i < len(bullets); i+=1 {
        bullet := &bullets[i]
        bullet.position += bullet.velocity
        if is_outside_screen(bullet.position) {
            unordered_remove_soa(bullets, i)
            i -= 1
            continue
        }

        damaged := try_damage_enemies(bullet.position, BULLET_RADIUS, bullet.damage, true, &global_enemies)
        if damaged {
            bullet.pierces -= 1
        }
        if bullet.pierces <= 0 {
            unordered_remove_soa(bullets, i)
            i -= 1
        }
    }
}


update_cannonballs :: proc(cannonballs: ^#soa[dynamic]CannonBall) {
    for i := 0; i < len(cannonballs); i+=1 {
        ball := &cannonballs[i]
        ball.position = rl.Vector2MoveTowards(ball.position, ball.target_position, ball.speed)

        if rl.Vector2Equals(ball.position, ball.target_position) {
            try_damage_enemies(ball.position, ball.damage_radius, ball.damage, false, &global_enemies)
            
            effect := particle.create_system()
            effect.position = ball.position
            effect.particle_sprite = TEX_FIRE_PARTICLE
            effect.emission_strength = 0.1 * ball.damage_radius
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
            particle.populate_system(&effect, int(0.2 * ball.damage_radius))

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

            play_random_sound(SOUND_RANDOM_EXPLOSION[:])

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

    effect := particle.create_system()
    effect.position = CENTER + player.facing_vector * 125
    effect.particle_sprite = TEX_LASER_FLASH_PARTICLE
    effect.angle = math.atan2_f32(player.facing_vector.y, player.facing_vector.x) * math.DEG_PER_RAD + 90
    effect.start_color = rl.Color{255, 255, 255, 220}
    effect.end_color = rl.Color{255, 255, 255, 0}
    effect.duration = 5
    effect.start_size = 0.15
    effect.end_size = 0.15
    particle.populate_system(&effect, 1)
    particle.add_to_system_group(&global_effects, effect)
}