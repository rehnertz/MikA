event_inherited()

/**
 * Get all instances to drive.
 * Requires:
 *   - Called before movement.
 * @self obj_block
 * @param {Real} dx
 * @param {Real} dy
 * @return {Array}
 */
get_drivees = use_method(function(dx, dy) {
    var drivees = []
    var list = ds_list_create()
    var margin = 1
    var n = collision_rectangle_list(
        bbox_left - margin, bbox_top - margin,
        bbox_right + margin, bbox_right + margin,
        GameObject, true, true, list, false
    )
    for (var i = 0; i < n; i++) {
        var collided = list[| i]
        if (collided.box && collided.is_beneath(self) && !probe(dx, dy, collided)) {
            array_push(drivees, collided)
        }
    }
    ds_list_destroy(list)
    return drivees
})

/**
 * Get all instances to push.
 * Requires:
 *   - Called before movement.
 * @self obj_block
 * @param {Real} dx
 * @param {Real} dy
 * @return {Array}
 */
get_pushees = use_method(function(dx, dy) {
    static filter = function(collided) { return collided.box && collided.is_beneath(self) }
    
    return get_probed(dx, dy, GameObject, false, filter)
})

/**
 * Drive another instance.
 * Requires:
 *  - Called after movement.
 * @self obj_block
 * @param {Real} dx
 * @param {Real} dy
 * @param {Id.Instance} drivee
 */
drive = use_method(function(dx, dy, drivee) {
    drivee.translate(dx, dy)
})

/**
 * Push another instance.
 * Requires:
 *  - Called after movement.
 * @self obj_block
 * @param {Real} dx
 * @param {Real} dy
 * @param {Id.Instance} pushee
 */
push = use_method(function(dx, dy, pushee) {
    var dist = point_distance(0, 0, dx, dy)
    if (dist == 0) {
        return
    }
    
    instance_deactivate_object(self)
    pushee.move_slide(dx, dy)
    instance_activate_object(self)
    
    // Due to rounding errors, the block may still collides with the pushee.
    var x_before = x
    var y_before = y
    var udx = dx / dist
    var udy = dy / dist
    // Try to move back block.
    var step = pushee.max_gap / 2
    var dist_travelled = 0
    while (pushee.cast_mask(pushee.x, pushee.y, self)) {
        translate(-step * udx, -step * udy)
        dist_travelled += step
        if (dist_travelled >= 2) {
            x = x_before
            y = y_before
            break
        }
    }
    
    // If the block does not move forward, we push the pushee outside instead.
    if (dot_product(udx, udy, x - x_before, y - y_before) <= 0) {
        x = x_before
        y = y_before
        
        step = max(dist, 8)
        instance_deactivate_object(self)
        pushee.move_slide(step * udx, step * udy)
        instance_activate_object(self)
        pushee.move_slide(-step * udx, -step * udy)
    }
})

/**
 * @self obj_block
 * @param {Real} dx
 * @param {Real} dy
 */
move = use_method(function(dx, dy) {
    if (dx == 0 && dy == 0) {
        return
    }
    var x_before = x
    var y_before = y
    translate(dx, dy)
    var x_after = x
    var y_after = y
    dx = x_after - x_before
    dy = y_after - y_before
    
    x = x_before
    y = y_before
    var drivees = get_drivees(dx, dy)
    var pushees = get_pushees(dx, dy)
    x = x_after
    y = y_after
    var n = array_length(drivees)
    for (var i = 0; i < n; i++) {
        drive(dx, dy, drivees[i])
    }
    n = array_length(pushees)
    for (var i = 0; i < n; i++) {
        push(dx, dy, pushees[i])
    }
})
