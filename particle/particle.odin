package particle

import "core:math"
import "core:math/rand"
import rl "vendor:raylib"
import "core:fmt"

MAX_PARTICLES_PER_FRAME :: 1000


Particle :: struct {
    position, velocity: rl.Vector2,
    angle, angular_velocity: f32,  // In degrees
    lifetime: int  // Remaining lifetime in frames
}

EmissionShape :: enum {
    Rect,
    Ring
}


System :: struct {
    max_particles: int,
    particles: #soa[dynamic]Particle,
    position: rl.Vector2,
    emission_strength, emission_strength_var, emission_angle, emission_angle_var: f32,
    emission_shape: EmissionShape,
    spread, force: rl.Vector2,
    drag: f32,
    angle: f32,
    angular_velocity, angular_velocity_var: f32,
    random_start_angle: bool,

    duration, duration_var: int,  // In frames

    particle_sprite: rl.Texture2D,
    start_color, end_color: rl.Color,
    start_size, end_size, size_var: f32,
    
    emission_interval, accumulated_time: f32,
    emitting: bool
}


SystemGroup :: struct {
    systems: [dynamic]System,
    auto_delete_after: f32,
    delete_timers: [dynamic]f32
}

@(private)
vary_f32 :: proc(base, var: f32) -> f32 {
    if var == 0 {
        return base
    }
    var := math.abs(var)
    return base + rand.float32_range(-var/2, var/2)
}

@(private)
vary_int :: proc(base, var: int) -> int {
    if var == 0 {
        return base
    }
    var := math.abs(var)
    return base + rand.int_range(-var/2, var/2)
}


@(private)
add_particle :: proc(system: ^System) {
    if (system.max_particles != -1 && len(system.particles) >= system.max_particles) {
        return
    }

    emission_angle := vary_f32(system.emission_angle, system.emission_angle_var)
    emission_vector :=  rl.Vector2Rotate(rl.Vector2{0, -1}, emission_angle)
    strength := vary_f32(system.emission_strength, system.emission_strength_var)
    velocity := emission_vector * strength

    position: rl.Vector2
    switch system.emission_shape {
        case .Rect:
            position = rl.Vector2{
                vary_f32(0, system.spread.x),
                vary_f32(0, system.spread.y),
            } + system.position
        case .Ring:
            factor := vary_f32(system.spread.x, system.spread.y)
            position = system.position + emission_vector * factor
    }


    angle := rand.float32_range(0, 360) if system.random_start_angle else system.angle
    angular_velocity := vary_f32(system.angular_velocity, system.angular_velocity_var)

    lifetime := vary_int(system.duration, system.duration_var)
    particle := Particle{position, velocity, angle, angular_velocity, lifetime}

    append_soa(&system.particles, particle)
}


create_system :: proc() -> System {
    system := System{}
    system.max_particles = -1
    system.emission_shape = .Rect
    return system
}


delete_system :: proc(system: ^System) {
    delete_soa(system.particles)
}


populate_system :: proc(system: ^System, particle_count: int) {
    for i in 0..<particle_count {
        add_particle(system)
    }
}


update_system :: proc(system: ^System, delta: f32) {
    if system.emitting {
        system.accumulated_time += delta
        added_particles := int(system.accumulated_time / system.emission_interval)
        if (added_particles > 0) {
            actual_added_particles := math.min(added_particles, MAX_PARTICLES_PER_FRAME)
            for i in 0..<actual_added_particles {
                add_particle(system)
            }
            system.accumulated_time -= f32(added_particles) * system.emission_interval
        }
    }

    for i := 0; i < len(system.particles); i+=1 {
        particle := &system.particles[i]
        particle.velocity = rl.Vector2MoveTowards(particle.velocity + system.force, rl.Vector2{0, 0}, system.drag)
        particle.position += particle.velocity
        particle.angle += particle.angular_velocity

        particle.lifetime -= 1
        if particle.lifetime <= 0 {
            unordered_remove_soa(&system.particles, i)
            i -= 1
        }
    }
}


draw_system :: proc(system: ^System) {
    source := rl.Rectangle{0, 0, f32(system.particle_sprite.width), f32(system.particle_sprite.height)};
    for particle in system.particles {
        lifetime_t := f32(particle.lifetime) / f32(system.duration)
        color := rl.ColorLerp(system.end_color, system.start_color, math.clamp(lifetime_t, 0, 1))
        size := rl.Lerp(system.end_size, system.start_size, lifetime_t)

        dest := rl.Rectangle{
            particle.position.x, particle.position.y,
            source.width * size, source.height * size
        };
        origin := rl.Vector2{source.width, source.height} / 2 * size
        
        rl.DrawTexturePro(system.particle_sprite, source, dest, origin, particle.angle, color)
        // rl.DrawCircle(i32(particle.position.x), i32(particle.position.y), 3, rl.RED)
    }
}


create_system_group :: proc(auto_delete_after: f32=-1.0) -> SystemGroup {
    systems_array: [dynamic]System
    if auto_delete_after == -1.0 {
        return SystemGroup{systems_array, auto_delete_after, nil}
    }
    delete_timers: [dynamic]f32
    return SystemGroup{systems_array, auto_delete_after, delete_timers}
}


delete_system_group :: proc(group: ^SystemGroup) {
    for &system in group.systems {
        delete_system(&system)
    }

    delete(group.systems)

    if group.delete_timers != nil {
        delete(group.delete_timers)
    }
}


add_to_system_group :: proc(group: ^SystemGroup, system: System) {
    append(&group.systems, system)
    if group.auto_delete_after != -1.0 {
        append(&group.delete_timers, 0.0)
    }
}


update_system_group :: proc(group: ^SystemGroup, delta: f32) {
    for i := 0; i < len(group.systems); i+=1 {
        system := &group.systems[i]
        update_system(system, delta)

        if group.auto_delete_after != -1 {
            if len(system.particles) == 0 {
                group.delete_timers[i] += delta
                if (group.delete_timers[i] >= group.auto_delete_after) {
                    delete_system(system)
                    unordered_remove(&group.systems, i)
                    unordered_remove(&group.delete_timers, i)
                    i -= 1
                }
            }
            else {
                group.delete_timers[i] = 0
            }
        }
    }
}


clear_system_group :: proc(group: ^SystemGroup) {
    for &system in group.systems {
        delete_system(&system)
    }
    
    clear_dynamic_array(&group.systems)
    clear_dynamic_array(&group.delete_timers)
}


draw_system_group :: proc(group: ^SystemGroup) {
    for &system in group.systems {
        draw_system(&system)
    }
}
