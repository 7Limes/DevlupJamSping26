package game

import rl "vendor:raylib"


tooltip_button :: proc(bounds: rl.Rectangle, text, tooltip_title, tooltip_description: cstring) -> bool {
    mouse := rl.GetMousePosition()
    if rl.CheckCollisionPointRec(mouse, bounds) {
        tooltip_rect := rl.Rectangle{bounds.x+bounds.width, mouse.y, 200, 70}
        rl.DrawRectangleRec(tooltip_rect, {0, 0, 0, 170})

        saved_text_size := rl.GuiGetStyle(.DEFAULT, 16)
        rl.GuiSetStyle(.DEFAULT, 16, 30)
        rl.GuiLabel({tooltip_rect.x+5, tooltip_rect.y, tooltip_rect.width, 30}, tooltip_title)
        rl.GuiSetStyle(.DEFAULT, 16, saved_text_size)
        rl.GuiTextBox(tooltip_rect, tooltip_description, 20, false)
    }

    return rl.GuiButton(bounds, text)
}