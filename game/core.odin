package game

import rl "vendor:raylib"


Entity :: struct {
    position, target: rl.Vector2,
    radius: f32,
    health: int
}


move_entity_toward_target :: proc(entity: ^Entity, amount: f32) {
    entity.position = rl.Vector2MoveTowards(entity.position, entity.target, amount)
}
