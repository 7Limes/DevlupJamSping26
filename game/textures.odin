package game

import rl "vendor:raylib"

TEX_FIRE_PARTICLE: rl.Texture2D
TEX_FLARE_PARTICLE: rl.Texture2D

load_textures :: proc() {
    TEX_FIRE_PARTICLE = rl.LoadTexture("assets/particle/fire_2.png")
    TEX_FLARE_PARTICLE = rl.LoadTexture("assets/particle/flare_16.png")
}