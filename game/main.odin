package game

import rl "vendor:raylib"


main :: proc() {
    rl.SetConfigFlags(rl.ConfigFlags{.MSAA_4X_HINT})
    rl.InitWindow(WIN_WIDTH, WIN_HEIGHT, "game")
    rl.SetTargetFPS(60)

    towers: #soa[dynamic]Tower
    enemies: #soa[dynamic]Enemy
    defer delete_soa(towers)
    defer delete_soa(enemies)

    append_soa(&towers, create_base_tower(HALF_WIN_SIZE))
    append_soa(&enemies, create_regular_dog(rl.Vector2{100, 100}))

    for !rl.WindowShouldClose() {
        update_enemies(&enemies)
        update_towers(&towers)

        rl.BeginDrawing()
            rl.ClearBackground(rl.RAYWHITE)

            draw_enemies(&enemies)
            draw_towers(&towers)

        rl.EndDrawing()
    }

    rl.CloseWindow()
}