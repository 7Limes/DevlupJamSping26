package game

import rl "vendor:raylib"

SOUND_RANDOM_EXPLOSION: [4]rl.Sound


load_audio :: proc() {
    rl.InitAudioDevice()
    SOUND_RANDOM_EXPLOSION[0] = rl.LoadSound("audio/explosion/explosion1.ogg")
    SOUND_RANDOM_EXPLOSION[1] = rl.LoadSound("audio/explosion/explosion2.ogg")
    SOUND_RANDOM_EXPLOSION[2] = rl.LoadSound("audio/explosion/explosion3.ogg")
    SOUND_RANDOM_EXPLOSION[3] = rl.LoadSound("audio/explosion/explosion4.ogg")
}