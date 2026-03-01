package game

import rl "vendor:raylib"


TEX_FIRE_PARTICLE: rl.Texture2D
TEX_FLARE_PARTICLE: rl.Texture2D
TEX_MUZZLE_FLASH_PARTICLE: rl.Texture2D
TEX_LASER_FLASH_PARTICLE: rl.Texture2D
TEX_SHIELD_PARTICLE: rl.Texture2D
TEX_IMPACT_PARTICLE: rl.Texture2D

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

TEX_CONVEYOR: rl.Texture2D

TEX_BACKGROUND: rl.Texture2D

WEAPON_TEXTURES: map[WeaponType]rl.Texture2D


load_textures :: proc() {
    TEX_FIRE_PARTICLE = rl.LoadTexture("assets/particle/fire_2.png")
    TEX_FLARE_PARTICLE = rl.LoadTexture("assets/particle/flare_16.png")
    TEX_MUZZLE_FLASH_PARTICLE = rl.LoadTexture("assets/particle/muzzle_flash_1.png")
    TEX_LASER_FLASH_PARTICLE = rl.LoadTexture("assets/particle/laser-flash.png")
    TEX_SHIELD_PARTICLE = rl.LoadTexture("assets/particle/shield.png")
    TEX_IMPACT_PARTICLE = rl.LoadTexture("assets/particle/impact.png")

    TEX_WEAPON_MG = rl.LoadTexture("assets/weapon/machine_gun.png")
    TEX_WEAPON_CANNON = rl.LoadTexture("assets/weapon/cannon.png")
    TEX_WEAPON_SHOTGUN = rl.LoadTexture("assets/weapon/shotgun.png")
    TEX_WEAPON_LASER = rl.LoadTexture("assets/weapon/laser.png")
    TEX_WEAPON_SNIPER = rl.LoadTexture("assets/weapon/sniper.png")

    TEX_ICON_BULLET = rl.LoadTexture("assets/icon/bullet-icon.png")
    TEX_ICON_MONEY = rl.LoadTexture("assets/icon/money-icon.png")
    TEX_ICON_HEART = rl.LoadTexture("assets/icon/heart-icon.png")

    TEX_NORMAL_ENEMY = rl.LoadTexture("assets/enemy/normal-enemy.png")
    TEX_BIG_ENEMY = rl.LoadTexture("assets/enemy/big-enemy.png")
    TEX_HUGE_ENEMY = rl.LoadTexture("assets/enemy/huge-enemy.png")

    TEX_LASER_BEAM = rl.LoadTexture("assets/projectile/laser-beam.png")

    TEX_CONVEYOR = rl.LoadTexture("assets/other/conveyor.png")

    TEX_BACKGROUND = rl.LoadTexture("assets/background/background.png")

    WEAPON_TEXTURES[.MachineGun] = TEX_WEAPON_MG
    WEAPON_TEXTURES[.Cannon] = TEX_WEAPON_CANNON
    WEAPON_TEXTURES[.Shotgun] = TEX_WEAPON_SHOTGUN
    WEAPON_TEXTURES[.Laser] = TEX_WEAPON_LASER
}
