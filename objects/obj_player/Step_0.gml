var dt = delta_time / 1000000
var l = keyboard_check(vk_right) - keyboard_check(vk_left)
var u = keyboard_check(vk_down) - keyboard_check(vk_up)

velocity.x = l * movement_speed

var on_ground = velocity.y >= 0 && obstructed_at(x + downdir.x, y + downdir.y)
if (on_ground) {
    jump_level = 0
    velocity.y = 0
} else {
    if (jump_level == 0) {
        jump_level = 1
    }
}

if (keyboard_check_pressed(vk_shift)) {
    var n = array_length(jump_speeds)
    if (jump_level < n) {
        velocity.y = -jump_speeds[jump_level++]
        on_ground = false
    }
}
if (velocity.y < 0 && keyboard_check_released(vk_shift)) {
    velocity.y *= 0.45
}

if (!on_ground) {
    velocity.y += grav * dt
    if (velocity.y > max_fall_speed) {
        velocity.y = max_fall_speed
    }
}

event_inherited()

if (obstructed_at(x, y)) {
    kill()
}

var vy = to_global(0, velocity.y * dt)
if (probe(vy.x, vy.y)) {
    velocity.y = 0
}
