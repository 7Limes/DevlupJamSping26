package game

import rl "vendor:raylib"


WIN_WIDTH :: 500
WIN_HEIGHT :: 500


main :: proc() {
    rl.SetConfigFlags(rl.ConfigFlags{.WINDOW_RESIZABLE})
    rl.InitWindow(WIN_WIDTH, WIN_HEIGHT, "game")
    rl.SetTargetFPS(60)

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
            rl.ClearBackground(rl.RAYWHITE)


        rl.EndDrawing()
    }

    rl.CloseWindow()
}