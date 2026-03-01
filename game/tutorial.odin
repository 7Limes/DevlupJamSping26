package game

import rl "vendor:raylib"
import "base:runtime"

TUTORIAL_DATA := []struct{rect: rl.Rectangle, content: cstring} {
    {{450, 50, 300, 175}, "Evil cats are invading and it's up to you to defend your homeland (the yard)!"},
    {{450, 550, 300, 175}, "Aim with your mouse, then press [LEFT CLICK] or [SHIFT] to fire."},
    {{200, 575, 300, 160}, "<--- Click this button to buy a random weapon."},
    {{700, 100, 300, 160}, "You can purchase weapon upgrades over here."},
    {{500, 50, 200, 140}, "Good Luck!"}
}

tutorial_index := 0


show_tutorial :: proc() {
    if tutorial_index >= len(TUTORIAL_DATA) {
        return
    }
    global_wave_data.wave_timer = 0 // Avoid progressing waves until tutorial is over

    data := TUTORIAL_DATA[tutorial_index]
    pressed_x := rl.GuiWindowBox(data.rect, "Tutorial")

    if pressed_x != 0 {
        tutorial_index = len(TUTORIAL_DATA)
    }

    saved_text_size := rl.GuiGetStyle(.DEFAULT, 16)
    saved_line_spacing := rl.GuiGetStyle(.DEFAULT, 20)
    rl.GuiSetStyle(.DEFAULT, 16, 25)
    rl.GuiSetStyle(.DEFAULT, 21, i32(rl.GuiTextAlignmentVertical.TEXT_ALIGN_TOP))
    rl.GuiSetStyle(.DEFAULT, 22, i32(rl.GuiTextWrapMode.TEXT_WRAP_WORD))

    when ODIN_OS == .Windows {
        // Fix weird line spacing bug
        rl.GuiSetStyle(.DEFAULT, 20, 0)
    }

    rl.GuiTextBox({data.rect.x, data.rect.y+23, data.rect.width, data.rect.height-23}, data.content, 20, false)

    rl.GuiSetStyle(.DEFAULT, 21, i32(rl.GuiTextAlignmentVertical.TEXT_ALIGN_MIDDLE))
    rl.GuiSetStyle(.DEFAULT, 22, i32(rl.GuiTextWrapMode.TEXT_WRAP_NONE))
    
    pressed_next := rl.GuiButton({data.rect.x+10, data.rect.y+data.rect.height-60, 70, 50}, "Next")
    if pressed_next {
        tutorial_index += 1
    }

    rl.GuiSetStyle(.DEFAULT, 16, saved_text_size)
    rl.GuiSetStyle(.DEFAULT, 20, saved_line_spacing)
}