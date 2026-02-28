package old

import rl "vendor:raylib"
import "core:fmt"

BASE_RADIUS :: 50
BASE_HEALTH :: 100

MELEE_RADIUS :: 20
MELEE_HEALTH :: 10
MELEE_SPEED :: 2.0
MELEE_DAMAGE :: 1

TowerType :: enum {
    Base,
    SwordGuy,
    Archer,
    Sniper,
    Laser
}

Tower :: struct {
    type: TowerType,
    entity: Entity
}

SOATower :: #soa ^#soa[dynamic]Tower


get_nearest_enemy :: proc(enemies: ^#soa[dynamic]Enemy, position: rl.Vector2) -> (SOAEnemy, f32) {
    nearest_distance: f32 = 999_999_999.0
    nearest: SOAEnemy = nil

    for i := 0; i < len(enemies); i+=1 {
        distance := rl.Vector2DistanceSqrt(enemies[i].entity.collider.position, position)
        if distance < nearest_distance {
            nearest_distance = distance
            nearest = &enemies[i]
        }
    }

    return nearest, nearest_distance
}


update_towers :: proc(towers: ^#soa[dynamic]Tower, enemies: ^#soa[dynamic]Enemy) {
    for i := 0; i < len(towers); i+=1 {
        tower_type := towers[i].type
        #partial switch tower_type {
            case .Base:
                towers[i].entity.collider.position = HALF_WIN_SIZE
            case .SwordGuy:
                update_melee(&towers[i], enemies)
            case .Archer:
            case .Sniper:
            case .Laser:
        }
    }
}


draw_towers :: proc(towers: ^#soa[dynamic]Tower) {
    for tower in towers {
        position := tower.entity.collider.position
        rl.DrawCircle(i32(position.x), i32(position.y), tower.entity.collider.radius, rl.BLUE)
    }
}


create_base_tower :: proc(position: rl.Vector2) -> Tower {
    return Tower{.Base, Entity{CollisionCircle{position, BASE_RADIUS}, rl.Vector2{0, 0}, BASE_HEALTH}}
}


create_sword_guy :: proc(position: rl.Vector2) -> Tower {
    return Tower{.SwordGuy, Entity{CollisionCircle{position, MELEE_RADIUS}, rl.Vector2{0, 0}, MELEE_HEALTH}}
}

update_melee :: proc(guy: SOATower, enemies: ^#soa[dynamic]Enemy) {
    nearest_enemy, distance := get_nearest_enemy(enemies, guy.entity.collider.position)
    if nearest_enemy == nil {
        return
    }
    guy.entity.target = nearest_enemy.entity.collider.position
    move_entity_toward_target(&guy.entity, MELEE_SPEED)
    target_radius := nearest_enemy.entity.collider.radius
    attack_distance := (target_radius+MELEE_RADIUS)*(target_radius+MELEE_RADIUS)
    fmt.println(distance, attack_distance)
    if distance < attack_distance {
        fmt.println("damaged")
        nearest_enemy.entity.health -= MELEE_DAMAGE
    }
}
