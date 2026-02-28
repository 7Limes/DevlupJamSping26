package game

import rl "vendor:raylib"

BASE_RADIUS :: 50
BASE_HEALTH :: 100

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



update_towers :: proc(towers: ^#soa[dynamic]Tower) {
    for i := 0; i < len(towers); i+=1 {
        
    }
}


draw_towers :: proc(towers: ^#soa[dynamic]Tower) {
    for tower in towers {
        position := tower.entity.position
        rl.DrawCircle(i32(position.x), i32(position.y), tower.entity.radius, rl.BLUE)
    }
}


create_base_tower :: proc(position: rl.Vector2) -> Tower {
    return Tower{.Base, Entity{position, rl.Vector2{0, 0}, BASE_RADIUS, BASE_HEALTH}}
}
