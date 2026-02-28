package game

import rl "vendor:raylib"


MG_AMMO_UPGRADES := []int{100, 150, 200, 300, 500}
MG_AMMO_COSTS := []int{50, 100, 200, 300}

MG_DAMAGE_UPGRADES := []f32{1, 1.5, 2, 3, 4}
MG_DAMAGE_COSTS := []int{50, 100, 200, 300}

MG_FIRE_UPGRADES := []int{10, 8, 6, 3, 1}
MG_FIRE_COSTS := []int{50, 100, 250, 350}


CANNON_SPEED_UPGRADES := []f32{4.0, 4.5, 5.0, 6.0, 7.0}
CANNON_SPEED_COSTS := []int{50, 100, 200, 300}

CANNON_DAMAGE_UPGRADES := []f32{5.0, 7.0, 9.0, 10.0, 12.0}
CANNON_DAMAGE_COSTS := []int{100, 250, 450, 600}

CANNON_RADIUS_UPGRADES := []f32{60.0, 75.0, 90.0, 110.0, 150.0}
CANNON_RADIUS_COSTS := []int{100, 250, 450, 600}


SHOTGUN_AMMO_UPGRADES := []int{30, 40, 50, 60, 75}
SHOTGUN_AMMO_COSTS := []int{50, 100, 200, 300}

SHOTGUN_DAMAGE_UPGRADES := []f32{3, 3.5, 4, 4.5, 5}
SHOTGUN_DAMAGE_COSTS := []int{50, 100, 200, 300}

SHOTGUN_BARREL_UPGRADES := []int{3, 4, 5, 6, 7}
SHOTGUN_BARREL_COSTS := []int{100, 200, 350, 500}


LASER_AMMO_UPGRADES := []int{300, 450, 600, 750, 1000}
LASER_AMMO_COSTS := []int{100, 200, 300, 500}

LASER_DAMAGE_UPGRADES := []f32{0.1, 0.25, 0.5, 0.75, 1.0}
LASER_DAMAGE_COSTS := []int{100, 250, 500, 750}

LASER_WIDTH_UPGRADES := []f32{50, 60, 70, 85, 100}
LASER_WIDTH_COSTS := []int{100, 200, 350, 500}


show_weapon_upgrade_ui :: proc(weapon_data: ^WeaponData) {
    rl.GuiPanel({1000, 0, 200, 800}, "Upgrades")

    switch weapon_data.current {
        case .MachineGun:
            show_machine_gun_ui(&weapon_data.machine_gun)
        case .Cannon:
            show_cannon_ui(&weapon_data.cannon)
        case .Shotgun:
            show_shotgun_ui(&weapon_data.shotgun)
        case .Laser:
            show_laser_ui(&weapon_data.laser)
    }
}

show_upgrade_option :: proc(y_pos: f32, name: cstring, value: ^$T, upgrades: []T, costs: []int) {
    saved_text_size := rl.GuiGetStyle(.DEFAULT, 16)
    rl.GuiSetStyle(.DEFAULT, 16, 30)

    level, ok := indexof(upgrades, value^)

    rl.GuiLabel({1010, y_pos, 200, 100}, name)
    rl.GuiLabel({1140, y_pos, 200, 100}, format_as_cstring("Lv %d", level+1))
    
    rl.DrawTextureEx(TEX_ICON_MONEY, {1090, y_pos+70}, 0, 2.0, rl.WHITE)
    
    cost_string: cstring = "MAX"
    next_level_exists := level < len(costs)
    if next_level_exists {
        cost_string = format_as_cstring("%d", costs[level])
    }
    rl.GuiSetStyle(.DEFAULT, 16, 22)
    rl.GuiLabel({1120, y_pos+72, 100, 30}, cost_string)
    rl.GuiSetStyle(.DEFAULT, 16, saved_text_size)
    
    button_pressed := rl.GuiButton({1010, y_pos+70, 80, 30}, "Upgrade")
    if button_pressed && next_level_exists && global_money >= costs[level] {
        global_money -= costs[level]
        value^ = upgrades[level+1]
    }
}

show_machine_gun_ui :: proc(machine_gun: ^MachineGun) {
    show_upgrade_option(100, "Ammo:", &machine_gun.max_ammo, MG_AMMO_UPGRADES, MG_AMMO_COSTS)
    show_upgrade_option(200, "Damage:", &machine_gun.damage, MG_DAMAGE_UPGRADES, MG_DAMAGE_COSTS)
    show_upgrade_option(300, "Fire Rate:", &machine_gun.fire_interval, MG_FIRE_UPGRADES, MG_FIRE_COSTS)
}

show_cannon_ui :: proc(cannon: ^Cannon) {
    show_upgrade_option(100, "Speed:", &cannon.speed, CANNON_SPEED_UPGRADES, CANNON_SPEED_COSTS)
    show_upgrade_option(200, "Damage:", &cannon.damage, CANNON_DAMAGE_UPGRADES, CANNON_DAMAGE_COSTS)
    show_upgrade_option(300, "Radius:", &cannon.radius, CANNON_RADIUS_UPGRADES, CANNON_RADIUS_COSTS)
}

show_shotgun_ui :: proc(shotgun: ^Shotgun) {
    show_upgrade_option(100, "Ammo:", &shotgun.max_ammo, SHOTGUN_AMMO_UPGRADES, SHOTGUN_AMMO_COSTS)
    show_upgrade_option(200, "Damage:", &shotgun.damage, SHOTGUN_DAMAGE_UPGRADES, SHOTGUN_DAMAGE_COSTS)
    show_upgrade_option(300, "Barrels:", &shotgun.barrels, SHOTGUN_BARREL_UPGRADES, SHOTGUN_BARREL_COSTS)
}

show_laser_ui :: proc(laser: ^Laser) {
    show_upgrade_option(100, "Ammo:", &laser.max_ammo, LASER_AMMO_UPGRADES, LASER_AMMO_COSTS)
    show_upgrade_option(200, "Damage:", &laser.damage, LASER_DAMAGE_UPGRADES, LASER_DAMAGE_COSTS)
    show_upgrade_option(300, "Width:", &laser.beam_width, LASER_WIDTH_UPGRADES, LASER_WIDTH_COSTS)
}