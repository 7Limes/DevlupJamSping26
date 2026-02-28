package game

import rl "vendor:raylib"


EnemyType :: enum {
    RegularDog,
    LargeDog,
    DogGunner,
    DogMortar
}


Enemy :: struct {
    type: EnemyType,
    entity: Entity,
}

SOAEnemy :: #soa ^#soa[dynamic]Enemy


REGULAR_DOG_SPEED :: 1.0
REGULAR_DOG_HEALTH :: 100


update_enemies :: proc(enemies: ^#soa[dynamic]Enemy) {
    for i := 0; i < len(enemies); i+=1 {
        enemy_type := enemies[i].type
        switch enemy_type {
            case .RegularDog:
                update_regular_dog(&enemies[i])
            case .LargeDog:
            case .DogGunner:
            case .DogMortar:
        }

        if enemies[i].entity.health <= 0 {
            unordered_remove_soa(enemies, i)
            i -= 1
        }
    }
}

draw_enemies :: proc(enemies: ^#soa[dynamic]Enemy) {
    for enemy in enemies {
        position := enemy.entity.collider.position
        rl.DrawCircle(i32(position.x), i32(position.y), enemy.entity.collider.radius, rl.RED)
    }
}


create_regular_dog :: proc(position: rl.Vector2) -> Enemy {
    return Enemy{.RegularDog, Entity{CollisionCircle{position, 20}, HALF_WIN_SIZE, REGULAR_DOG_HEALTH}}
}

update_regular_dog :: proc(dog: SOAEnemy) {
    move_entity_toward_target(&dog.entity, REGULAR_DOG_SPEED)
}