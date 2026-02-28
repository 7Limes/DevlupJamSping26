package game

import rl "vendor:raylib"


// Resolves collisions between towers and enemies
resolve_collisions :: proc(towers: ^#soa[dynamic]Tower, enemies: ^#soa[dynamic]Enemy) {
    for &tower in towers {
        for &enemy in enemies {
            resolve_collision(&tower.entity.collider, &enemy.entity.collider)
        }
    }
}


main :: proc() {
    rl.SetConfigFlags(rl.ConfigFlags{.MSAA_4X_HINT})
    rl.InitWindow(WIN_WIDTH, WIN_HEIGHT, "game")
    rl.SetTargetFPS(60)

    towers: #soa[dynamic]Tower
    enemies: #soa[dynamic]Enemy
    defer delete_soa(towers)
    defer delete_soa(enemies)

    append_soa(&towers, create_base_tower(HALF_WIN_SIZE))
    append_soa(&enemies, create_regular_dog({100, 100}))
    append_soa(&towers, create_sword_guy({500, 400}))

    for !rl.WindowShouldClose() {
        update_enemies(&enemies)
        update_towers(&towers, &enemies)
        resolve_collisions(&towers, &enemies)

        rl.BeginDrawing()
            rl.ClearBackground(rl.RAYWHITE)

            draw_enemies(&enemies)
            draw_towers(&towers)

        rl.EndDrawing()
    }

    rl.CloseWindow()
}