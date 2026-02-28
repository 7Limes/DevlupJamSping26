package game

import rl "vendor:raylib"


show_weapon_upgrade_ui :: proc() {
    rl.GuiPanel({1000, 0, 200, 800}, "Upgrades")
}