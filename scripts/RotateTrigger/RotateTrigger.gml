/**
 * Trigger of rotation.
 * @param {Real} index Trigger index.
 * @param {Struct} options Trigger options: center, angle, duration, easing.
 * @param {Id.Instance} [inst] Instance to bind with.
 */
function RotateTrigger(index, options, inst = other) : Trigger(index, inst) constructor {
    center_ratio = options[$ "center"]
    angle = options.angle
    duration = options[$ "duration"] ?? angle / options.speed
    easing = options[$ "easing"] ?? easing_linear
    timer = 0
    
    static on_start = function() {
        var spr_xoff = sprite_get_xoffset(inst.sprite_index)
        var spr_yoff = sprite_get_yoffset(inst.sprite_index)
        var rot_xoff = spr_xoff
        var rot_yoff = spr_yoff
        if (center_ratio != undefined) {
            rot_xoff = sprite_get_width(inst.sprite_index) * clamp(center_ratio.x, 0, 1)
            rot_yoff = sprite_get_height(inst.sprite_index) * clamp(center_ratio.y, 0, 1)
        }
        offset = new Vector(rot_xoff - spr_xoff, rot_yoff - spr_yoff)
        offset.x *= inst.image_xscale
        offset.y *= inst.image_yscale
        offset.rotate_(inst.image_angle)
        rot_center = offset.add(inst.x, inst.y)
        offset.negative_()
        
        start_angle = inst.image_angle
        end_angle = start_angle + angle
    }
    
    static on_update = function() {
        timer += delta_time / 1000000
        var ratio = easing(timer / duration)
        var angle = lerp(start_angle, end_angle, ratio)
        var off = offset.rotate(angle - start_angle)
        inst.x = rot_center.x + off.x
        inst.y = rot_center.y + off.y
        inst.image_angle = angle
        if (timer >= duration) {
            finish()
        }
    }
}
