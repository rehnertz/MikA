/// Feather use syntax-errors

/**
 * Trigger of path.
 * @param {Real} index Trigger index.
 * @param {Struct} options Trigger options: path, scale, easing, duration.
 * @param {Id.Instance} [inst] Instance to bind with.
 */
function PathTrigger(index, options, inst = other) : Trigger(index, inst) constructor {
    path = options.path
    scale = options[$ "scale"] ?? 1
    easing = options[$ "easing"] ?? easing_linear
    timer = 0
    duration = options[$ "duration"]
    if (duration == undefined) {
        var spd = options.speed
        var len = path_get_length(path)
        duration = len * scale / spd
    }
    
    static on_update = function() {
        var prev_path_pos = easing(timer / duration)
        var prev_path_x = path_get_x(path, prev_path_pos)
        var prev_path_y = path_get_y(path, prev_path_pos)
        timer += delta_time / 1000000
        var path_pos = easing(timer / duration)
        var path_x = path_get_x(path, path_pos)
        var path_y = path_get_y(path, path_pos)
        var dx = (path_x - prev_path_x) * scale
        var dy = (path_y - prev_path_y) * scale
        inst.move(dx, dy)
        if (timer >= duration) {
            finish()
        }
    }
}
