package game

import rl "vendor:raylib"

AliasPool :: struct {
    index: int,
    sounds: [4]rl.Sound
}

SOUND_RANDOM_EXPLOSION: [4]rl.Sound

SOUND_ASSAULT_SHOT: rl.Sound
SOUND_SHOTGUN_SHOT: rl.Sound

SOUND_ERROR: rl.Sound
SOUND_UPGRADE: rl.Sound
SOUND_BUY: rl.Sound

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


play_aliased_sound :: proc(pool: ^AliasPool) {
    rl.PlaySound(pool.sounds[pool.index])
    pool.index = (pool.index + 1) % len(pool.sounds)
}

load_sound :: proc(sound_path: string) -> rl.Sound {
    path := format_as_cstring("%s%s", rl.GetApplicationDirectory(), sound_path)
    return rl.LoadSound(path)
}

load_music :: proc(music_path: string) -> rl.Music {
    path := format_as_cstring("%s%s", rl.GetApplicationDirectory(), music_path)
    return rl.LoadMusicStream(path)
}


load_audio :: proc() {
    rl.InitAudioDevice()
    
    SOUND_RANDOM_EXPLOSION[0] = load_sound("assets/audio/explosion/explosion1.ogg")
    SOUND_RANDOM_EXPLOSION[1] = load_sound("assets/audio/explosion/explosion2.ogg")
    SOUND_RANDOM_EXPLOSION[2] = load_sound("assets/audio/explosion/explosion3.ogg")
    SOUND_RANDOM_EXPLOSION[3] = load_sound("assets/audio/explosion/explosion4.ogg")

    SOUND_ERROR = load_sound("assets/audio/ui/error.ogg")
    SOUND_UPGRADE = load_sound("assets/audio/ui/upgrade.ogg")
    SOUND_BUY = load_sound("assets/audio/ui/buy.ogg")
    
    SOUND_ASSAULT_SHOT = load_sound("assets/audio/shot/assault-shot-last.ogg")
    SOUND_SHOTGUN_SHOT = load_sound("assets/audio/shot/shotgun-shot.ogg")
    SHOTGUN_SOUND_POOL = create_alias_pool(&SOUND_SHOTGUN_SHOT)

    SOUND_LASER_LOOP = load_music("assets/audio/laser/beam-loop.ogg")
}
