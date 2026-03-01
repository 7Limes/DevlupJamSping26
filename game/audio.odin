package game

import rl "vendor:raylib"

AliasPool :: struct {
    index: int,
    sounds: [4]rl.Sound
}

SOUND_RANDOM_EXPLOSION: [4]rl.Sound

SOUND_ASSAULT_SHOT: rl.Sound
SOUND_SHOTGUN_SHOT: rl.Sound

SOUND_LASER_LOOP: rl.Music

SHOTGUN_SOUND_POOL: AliasPool


create_alias_pool :: proc(source: ^rl.Sound) -> AliasPool {
    pool: AliasPool
    pool.index = 0;

    for i in 0..<len(pool.sounds) {
        pool.sounds[i] = rl.LoadSoundAlias(source^)
    }

    return pool
}

unload_alias_pool :: proc(pool: ^AliasPool) {
    for sound in pool.sounds {
        rl.UnloadSoundAlias(sound)
    }
}


play_aliased_sound :: proc(pool: ^AliasPool) {
    rl.PlaySound(pool.sounds[pool.index])
    pool.index = (pool.index + 1) % len(pool.sounds)
}


load_audio :: proc() {
    rl.InitAudioDevice()
    SOUND_RANDOM_EXPLOSION[0] = rl.LoadSound("audio/explosion/explosion1.ogg")
    SOUND_RANDOM_EXPLOSION[1] = rl.LoadSound("audio/explosion/explosion2.ogg")
    SOUND_RANDOM_EXPLOSION[2] = rl.LoadSound("audio/explosion/explosion3.ogg")
    SOUND_RANDOM_EXPLOSION[3] = rl.LoadSound("audio/explosion/explosion4.ogg")

    SOUND_ASSAULT_SHOT = rl.LoadSound("audio/shot/assault-shot-last.ogg")

    SOUND_SHOTGUN_SHOT = rl.LoadSound("audio/shot/shotgun-shot.ogg")
    SHOTGUN_SOUND_POOL = create_alias_pool(&SOUND_SHOTGUN_SHOT)

    SOUND_LASER_LOOP = rl.LoadMusicStream("audio/laser/beam-loop.ogg")
}
