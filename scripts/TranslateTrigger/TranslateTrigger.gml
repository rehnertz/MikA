/**
 * Trigger of translation.
 * @param {Real} index Trigger index.
 * @param {Struct} options Trigger options: displacement, duration, speed, direction, easing.
 * @param {Id.Instance} [inst] Instance to bind with.
 */
function TranslateTrigger(index, options, inst = other) : Trigger(index, inst) constructor {
    displacement = options[$ "displacement"]
    easing = options[$ "easing"] ?? easing_linear
    timer = 0
    if (displacement != undefined) {
        is_finite = true
        duration = options[$ "duration"]
        if (duration == undefined) {
            var spd = options.speed
            var dist = displacement.magnitude()
            duration = dist / spd
        }
    } else {
        is_finite = false
        var dir = options.direction
        direction = new Vector(dcos(dir), -dsin(dir))
        speed = options.speed
    }
    
    static on_start = function() {
        start_x = inst.x
        start_y = inst.y
        if (is_finite) {
            end_x = start_x + displacement.x
            end_y = start_y + displacement.y
        }
    }
    
    static on_update = function() {
        var dt = delta_time / 1000000
        if (!is_finite) {
            inst.move(speed * direction.x * dt, speed * direction.y * dt)
        } else {
            timer += dt
            var ratio = easing(timer / duration)
            var prev_x = inst.x
            var prev_y = inst.y
            var next_x = lerp(start_x, end_x, ratio)
            var next_y = lerp(start_y, end_y, ratio)
            inst.move(next_x - prev_x, next_y - prev_y)
            if (timer >= duration) {
                finish()
            }
        }
    }
}
