package game

import rl "vendor:raylib"
import "core:fmt"

MG_BASE_AMMO :: 100
MG_BASE_FIRE_RATE :: 10
MG_BASE_DAMAGE :: 1
MG_BULLET_SPEED :: 5.0

CANNON_BASE_AMMO :: 10
CANNON_BASE_RADIUS :: 30
CANNON_BASE_DAMAGE :: 5

SHOTGUN_BASE_AMMO :: 30
SHOTGUN_BASE_FIRE_RATE :: 10
SHOTGUN_BASE_DAMAGE :: 2


Bullet :: struct {
    position, velocity: rl.Vector2,
    damage: f32,
    pierces: int
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

    machine_gun: MachineGun,
    cannon: Cannon,
    shotgun: Shotgun,
}

create_weapon_data :: proc() -> WeaponData {
    bullets: #soa[dynamic]Bullet

    return {
        .MachineGun, MG_BASE_AMMO, 0,
        bullets,
        MachineGun{MG_BASE_AMMO, MG_BASE_FIRE_RATE, MG_BASE_DAMAGE, false},
        Cannon{CANNON_BASE_AMMO, CANNON_BASE_RADIUS, CANNON_BASE_DAMAGE},
        Shotgun{SHOTGUN_BASE_AMMO, SHOTGUN_BASE_FIRE_RATE, SHOTGUN_BASE_DAMAGE, 3},
    }
}

delete_weapon_data :: proc(weapon_data: ^WeaponData) {
    delete_soa(weapon_data.bullets)
}


shoot_weapon :: proc(weapon_data: ^WeaponData, shoot_point, facing_vector: rl.Vector2) -> bool {
    if weapon_data.ammo <= 0 || weapon_data.fire_cooldown > 0 {
        return false
    }

    switch (weapon_data.current) {
        case .MachineGun:
            shoot_machine_gun(weapon_data, shoot_point, facing_vector)
        case .Cannon:
        case .Shotgun:
        case .Laser:
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


update_weapons :: proc(weapon_data: ^WeaponData, enemies: ^#soa[dynamic]Enemy) {
    if weapon_data.fire_cooldown > 0 {
        weapon_data.fire_cooldown -= 1
    }

    update_bullets(&weapon_data.bullets, enemies)
}


update_bullets :: proc(bullets: ^#soa[dynamic]Bullet, enemies: ^#soa[dynamic]Enemy) {
    for i := 0; i < len(bullets); i+=1 {
        bullet := &bullets[i]
        bullet.position += bullet.velocity
        if bullet.position.x < 0 || bullet.position.x >= WIN_WIDTH || 
            bullet.position.y < 0 || bullet.position.y >= WIN_HEIGHT {
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