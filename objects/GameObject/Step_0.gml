/// @desc Default motion.

var dt = delta_time / 1000000
var v = to_global(velocity).mul_(dt)
move(v.x, v.y)

update_trigger()
