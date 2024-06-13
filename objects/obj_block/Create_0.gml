/// Feather use syntax-errors

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
    var margin = max(abs(dx), abs(dy), 2)
    var n = collision_rectangle_list(
        bbox_left - margin, bbox_top - margin,
        bbox_right + margin, bbox_bottom + margin,
        obj_kinematic, true, true, list, false
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
    static filter = function(collided) { return collided.box }
    
    return get_probed(dx, dy, obj_kinematic, false, filter)
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
    var adjusted_disp = drivee.compute_driven_displacement(dx, dy)
    drivee.translate(adjusted_disp.x, adjusted_disp.y)
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
    if (cast_mask(x, y, pushee)) {
        var udx = dx / dist
        var udy = dy / dist
        do {
            instance_deactivate_object(self)
            var obstructed = pushee.move_slide(udx, udy)
            instance_activate_object(self)
            if (obstructed) {
                break
            }
        } until (!cast_mask(x, y, pushee))
    }
})

/**
 * @self obj_block
 * @param {Real} dx
 * @param {Real} dy
 */
move = use_method(function(dx, dy) {
    #region Move horizontally.
    if (dx != 0) {
        var x_before = x
        translate(dx, 0)
        var x_after = x
        x = x_before
        var actual_dx = x_after - x_before
        var drivees = get_drivees(actual_dx, 0)
        var pushees = get_pushees(actual_dx, 0)
        x = x_after
        var n = array_length(drivees)
        for (var i = 0; i < n; i++) {
            drive(actual_dx, 0, drivees[i])
        }
        n = array_length(pushees)
        for (var i = 0; i < n; i++) {
            push(actual_dx, 0, pushees[i])
        }
    }
    #endregion
    
    #region Move vertically.
    if (dy != 0) {
        var y_before = y
        translate(0, dy)
        var y_after = y
        y = y_before
        var actual_dy = y_after - y_before
        var drivees = get_drivees(0, actual_dy)
        var pushees = get_pushees(0, actual_dy)
        y = y_after
        var n = array_length(drivees)
        for (var i = 0; i < n; i++) {
            drive(0, actual_dy, drivees[i])
        }
        n = array_length(pushees)
        for (var i = 0; i < n; i++) {
            push(0, actual_dy, pushees[i])
        }
    }
    #endregion
})

