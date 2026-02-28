package old

import rl "vendor:raylib"


CollisionCircle :: struct {
    position: rl.Vector2,
    radius: f32
}

Entity :: struct {
    collider: CollisionCircle,
    target: rl.Vector2,
    health: int
}


move_entity_toward_target :: proc(entity: ^Entity, amount: f32) {
    entity.collider.position = rl.Vector2MoveTowards(entity.collider.position, entity.target, amount)
}


resolve_collision :: proc(c1, c2: ^CollisionCircle) {
    distance := rl.Vector2Distance(c1.position, c2.position)
    if (distance > c1.radius + c2.radius) {
        return
    }

    // Get the collision normal (direction from c2 to c1)
    collision_normal: rl.Vector2
    if distance == 0 {
        // Circles are perfectly overlapping, push in arbitrary direction
        collision_normal = {1, 0}
    } else {
        collision_normal = rl.Vector2Normalize(c1.position - c2.position)
    }

    // Separate the circles so they no longer overlap
    overlap := (c1.radius + c2.radius) - distance
    c1.position += collision_normal * (overlap / 2)
    c2.position -= collision_normal * (overlap / 2)
}