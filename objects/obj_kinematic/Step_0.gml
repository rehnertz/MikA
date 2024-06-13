/// @desc Default motion.

/// Feather use syntax-errors

var dt = delta_time / 1000000
var vx = to_global(velocity.x * dt, 0)
if (move(vx.x, 0) || move(0, vx.y)) {
    velocity.x = 0
}
var vy = to_global(0, velocity.y * dt)
if (move(vy.x, 0) || move(0, vy.y)) {
    velocity.y = 0
}
update_trigger()
