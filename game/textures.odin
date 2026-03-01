package game

import rl "vendor:raylib"


TEX_FIRE_PARTICLE: rl.Texture2D
TEX_FLARE_PARTICLE: rl.Texture2D
TEX_MUZZLE_FLASH_PARTICLE: rl.Texture2D
TEX_LASER_FLASH_PARTICLE: rl.Texture2D
TEX_SHIELD_PARTICLE: rl.Texture2D
TEX_IMPACT_PARTICLE: rl.Texture2D
TEX_SHOTGUN_SHELL_PARTICLE: rl.Texture2D
TEX_SMOKE_PARTICLE: rl.Texture2D

TEX_WEAPON_MG: rl.Texture2D
TEX_WEAPON_CANNON: rl.Texture2D
TEX_WEAPON_SHOTGUN: rl.Texture2D
TEX_WEAPON_LASER: rl.Texture2D
TEX_WEAPON_SNIPER: rl.Texture2D

TEX_ICON_BULLET: rl.Texture2D
TEX_ICON_MONEY: rl.Texture2D
TEX_ICON_HEART: rl.Texture2D

TEX_LASER_BEAM: rl.Texture2D

TEX_NORMAL_ENEMY: rl.Texture2D
TEX_BIG_ENEMY: rl.Texture2D
TEX_HUGE_ENEMY: rl.Texture2D

TEX_DOG_SUSPICIOUS: rl.Texture2D

TEX_CONVEYOR: rl.Texture2D
TEX_LOGO: rl.Texture2D

TEX_BACKGROUND: rl.Texture2D
TEX_TITLE_BACKGROUND: rl.Texture2D

WEAPON_TEXTURES: map[WeaponType]rl.Texture2D

load_texture :: proc(texture_path: string) -> rl.Texture2D {
    path := format_as_cstring("%s%s", rl.GetApplicationDirectory(), texture_path)
    return rl.LoadTexture(path)
}


load_textures :: proc() {
    TEX_FIRE_PARTICLE = load_texture("assets/particle/fire_2.png")
    TEX_FLARE_PARTICLE = load_texture("assets/particle/flare_16.png")
    TEX_MUZZLE_FLASH_PARTICLE = load_texture("assets/particle/muzzle_flash_1.png")
    TEX_LASER_FLASH_PARTICLE = load_texture("assets/particle/laser-flash.png")
    TEX_SHIELD_PARTICLE = load_texture("assets/particle/shield.png")
    TEX_IMPACT_PARTICLE = load_texture("assets/particle/impact.png")
    TEX_SHOTGUN_SHELL_PARTICLE = load_texture("assets/particle/shotgun-shell.png")
    TEX_SMOKE_PARTICLE = load_texture("assets/particle/smoke.png")

    TEX_WEAPON_MG = load_texture("assets/weapon/machine_gun.png")
    TEX_WEAPON_CANNON = load_texture("assets/weapon/cannon.png")
    TEX_WEAPON_SHOTGUN = load_texture("assets/weapon/shotgun.png")
    TEX_WEAPON_LASER = load_texture("assets/weapon/laser.png")
    TEX_WEAPON_SNIPER = load_texture("assets/weapon/sniper.png")

    TEX_ICON_BULLET = load_texture("assets/icon/bullet-icon.png")
    TEX_ICON_MONEY = load_texture("assets/icon/money-icon.png")
    TEX_ICON_HEART = load_texture("assets/icon/heart-icon.png")

    TEX_NORMAL_ENEMY = load_texture("assets/enemy/normal.png")
    TEX_BIG_ENEMY = load_texture("assets/enemy/big.png")
    TEX_HUGE_ENEMY = load_texture("assets/enemy/huge.png")

    TEX_DOG_SUSPICIOUS = load_texture("assets/dog/sus-dog.png")

    TEX_LASER_BEAM = load_texture("assets/projectile/laser-beam.png")

    TEX_CONVEYOR = load_texture("assets/other/conveyor.png")
    TEX_LOGO = load_texture("assets/other/logo.png")

    TEX_BACKGROUND = load_texture("assets/background/background.png")
    TEX_TITLE_BACKGROUND = load_texture("assets/background/sky.png")

    WEAPON_TEXTURES[.MachineGun] = TEX_WEAPON_MG
    WEAPON_TEXTURES[.Cannon] = TEX_WEAPON_CANNON
    WEAPON_TEXTURES[.Shotgun] = TEX_WEAPON_SHOTGUN
    WEAPON_TEXTURES[.Laser] = TEX_WEAPON_LASER
}
