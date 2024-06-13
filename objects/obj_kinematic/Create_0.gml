/// @desc Kinematic motion declarations.

/// Feather use syntax-errors

downdir = new Vector(0, 1)
substep = max(
    (bbox_right - bbox_left) / 2,
    (bbox_bottom - bbox_top) / 2,
    8
)
max_gap = 0.25
floor_snap = 8
box = false
velocity = new Vector()
_trigger = undefined
_driven_x = 0

/**
 * Bind a trigger.
 * @self obj_kinematic
 * @param {Struct} trigger
 */
setup_trigger = use_method(function(trigger) {
    _trigger = trigger
})

/**
 * Trigger behaviour.
 * @self obj_kinematic
 */
update_trigger = use_method(function() {
    if (_trigger != undefined) {
        var state = _trigger.get_state()
        var index = _trigger.get_index()
        if (state == TriggerState.Finished) {
            _trigger = undefined
        } else {
            if (state == TriggerState.Inactive && (index == -1 || index == global.triggered_index)) {
                _trigger.start()
            }
            _trigger.update()
        }
    }
})

/**
 * Transform a global vector into local coordinate system.
 * @self obj_kinematic
 * @param {Real, Struct.Vector} x
 * @param {Real} [y]
 * @return {Struct.Vector}
 */
to_local = use_method(function(_x, _y = 0) {
    if (is_instanceof(_x, Vector)) {
        _y = _x.y
        _x = _x.x
    }
    return new Vector(
        dot_product(downdir.y, -downdir.x, _x, _y),
        dot_product(downdir.x, downdir.y, _x, _y)
    )
})
    
/**
 * Transform a local vector into global coordinate system.
 * @self obj_kinematic
 * @param {Real, Struct.Vector} x
 * @param {Real} [y]
 * @return {Struct.Vector}
 */
to_global = use_method(function(_x, _y = 0) {
    if (is_instanceof(_x, Vector)) {
        _y = _x.y
        _x = _x.x
    }
    return new Vector(
        dot_product(downdir.y, downdir.x, _x, _y),
        dot_product(-downdir.x, downdir.y, _x, _y)
    )
})

/**
 * Built-in function place_meeting with filter.
 * Assuming current instance is placed at (x, y),
 * check whether it collides with specific instances.
 * Collided instances that fail to pass the filter will be ignored.
 * If the object is not provided, use obstructed_at instead (fileter will be ignored).
 * @self obj_kinematic
 * @param {Real} x
 * @param {Real} y
 * @param {Asset.GMObject, Id.Instance, Id.TileMapElement, Constant.All, Array} [obj]
 * @param {Function} [filter] Function (instance) => Bool which filter out the collided instances.
 * @return {Bool}
 */
cast_mask = use_method(function(_x, _y, obj = undefined, filter = undefined) {
    if (obj == undefined) {
        return obstructed_at(_x, _y)
    }
    
    if (!is_callable(filter)) {
        return place_meeting(_x, _y, obj)
    }
    
    var has_collided = false
    var list = ds_list_create()
    var n = instance_place_list(_x, _y, obj, list, false)
    for (var i = 0; i < n; i++) {
        var collided = list[| i]
        if (filter(collided)) {
            has_collided = true
            break
        }
    }
    ds_list_destroy(list)
    return has_collided
})

/**
 * Built-in function instance_place_list with filter and returns array.
 * Assuming current instance is placed at (x, y), get all instances it collides with.
 * Collided instances that fail to pass the filter will be ignored.
 * @self obj_kinematic
 * @param {Real} x
 * @param {Real} y
 * @param {Asset.GMObject, Id.Instance, Id.TileMapElement, Constant.All, Array} obj
 * @param {Bool} ordered
 * @param {Function} [filter] Function (instance) => Bool which filter out the collided instances.
 * @return {Array}
 */
get_casted_by_mask = use_method(function(_x, _y, obj, ordered, filter = undefined) {
    var casted = []
    var list = ds_list_create()
    var n = instance_place_list(_x, _y, obj, list, ordered)
    for (var i = 0; i < n; i++) {
        var collided = list[| i]
        if (!is_callable(filter) || filter(collided)) {
            array_push(casted, collided)
        }
    }
    ds_list_destroy(list)
    return casted
})

/**
 * Probe whether there are any instances (of specific object) on the displacement (dx, dy).
 * Probed instances that fail to pass the filter will be ignored.
 * If the object is not provided, use obstructed_at instead.
 * @self obj_kinematic
 * @param {Real} dx
 * @param {Real} dy
 * @param {Asset.GMObject, Id.Instance, Id.TileMapElement, Constant.All, Array} [obj]
 * @param {Function} [filter] Function (instance) => Bool which filter out the collided instances.
 * @return {Bool}
 */
probe = use_method(function(dx, dy, obj = undefined, filter = undefined) {
    if (cast_mask(x, y, obj, filter)) {
        return true
    }
    var dist = point_distance(0, 0, dx, dy)
    if (dist == 0) {
        return false
    }
    var udx = dx / dist
    var udy = dy / dist
    var probe_x = x
    var probe_y = y
    // Move forward by substep.
    var dist_to_travel = dist
    while (dist_to_travel > 0) {
        var step = min(substep, dist_to_travel)
        probe_x += step * udx
        probe_y += step * udy
        if (cast_mask(probe_x, probe_y, obj, filter)) {
            return true
        }
        dist_to_travel -= substep
    }
    return false
})

/**
 * Get all instances (of specific object) on the displacement (dx, dy).
 * Probed instances that fail to pass the filter will be ignored.
 * @self obj_kinematic
 * @param {Real} dx
 * @param {Real} dy
 * @param {Asset.GMObject, Id.Instance, Id.TileMapElement, Constant.All, Array} obj
 * @param {Bool} ordered
 * @param {Function} [filter] Function (instance) => Bool which filter out the collided instances.
 * @return {Array}
 */
get_probed = use_method(function(dx, dy, obj, ordered, filter = undefined) {
    var probed = get_casted_by_mask(x, y, obj, ordered, filter)
    var dist = point_distance(0, 0, dx, dy)
    if (dist == 0) {
        return probed
    }
    
    // Deactivate probed instances to avoid duplications.
    var n = array_length(probed)
    for (var i = 0; i < n; i++) {
        instance_deactivate_object(probed[i])
    }
    
    var udx = dx / dist
    var udy = dy / dist
    var probe_x = x
    var probe_y = y
    var dist_to_travel = dist
    while (dist_to_travel > 0) {
        var step = min(substep, dist_to_travel)
        probe_x += step * udx
        probe_y += step * udy
        
        var casted = get_casted_by_mask(probe_x, probe_y, obj, ordered, filter)
        n = array_length(casted)
        for (var i = 0; i < n; i++) {
            var collided = casted[i]
            if (!is_callable(filter) || filter(collided)) {
                array_push(probed, collided)
                instance_deactivate_object(collided)
            }
        }
        dist_to_travel -= substep
    }
    
    n = array_length(probed)
    for (var i = 0; i < n; i++) {
        instance_activate_object(probed[i])
    }
    
    return probed
})

/**
 * Check whether an instance is beneath self.
 * @self obj_kinematic
 * @param {Id.Instance} instance
 * @return {Bool}
 */
is_beneath = use_method(function(instance) {
    if (cast_mask(x, y, instance)) {
        return false
    }
    var ub = point_distance(
        min(bbox_left, instance.bbox_left),
        min(bbox_top, instance.bbox_top),
        max(bbox_right, instance.bbox_right),
        max(bbox_bottom, instance.bbox_bottom)
    )
    return probe(ub * downdir.x, ub * downdir.y, instance)
})

/**
 * Move along displacement (dx, dy) and touch to obstacles.
 * Requires:
 *   - point_distance(0, 0, dx, dy) <= substep.
 * @self obj_kinematic
 * @param {Real} dx
 * @param {Real} dy
 */
touch = use_method(function(dx, dy) {
    if (!obstructed_at(x + dx, y + dy)) {
        x += dx
        y += dy
        return
    }
    
    var dist = point_distance(0, 0, dx, dy)
    if (dist == 0) {
        return
    }
    var udx = dx / dist
    var udy = dy / dist
    var step = dist / 2;
    var min_step = max_gap / 2
    while (step >= min_step) {
        var x_next = x + step * udx
        var y_next = y + step * udy
        if (!obstructed_at(x_next, y_next)) {
            x = x_next
            y = y_next
        }
        step /= 2
    }
})

/**
 * Move along displacement (dx, dy) until touching obstacles.
 * @self obj_kinematic
 * @param {Real} dx
 * @param {Real} dy
 * @return {Bool} Whether the movement is obstructed.
 */
translate = use_method(function(dx, dy) {
    if (obstructed_at(x, y)) {
        return true
    }
    var dist = point_distance(0, 0, dx, dy)
    if (dist == 0) {
        return false
    }
    
    var udx = dx / dist
    var udy = dy / dist
    var dist_to_travel = dist
    while (dist_to_travel > 0) {
        var step = min(substep, dist_to_travel)
        var x_next = x + step * udx
        var y_next = y + step * udy
        if (!obstructed_at(x_next, y_next)) {
            x = x_next
            y = y_next
        } else {
            touch(step * udx, step * udy)
            return true
        }
        dist_to_travel -= substep
    }
    return false
})

/**
 * Move along displacement (dx, dy) until touching obstacles.
 * If the movement is obstructed, the displacement will be decomposed
 * in the local coordinate system.
 * @self obj_kinematic
 * @param {Real} dx
 * @param {Real} dy
 * @return {Real} A 2-bit mask whose lower and upper bit stand for 
 *   whether the movement is obstructed in the local x and y direction respectively.
 */
translate_orthogonal = use_method(function(dx, dy) {
    var x_original = x
    var y_original = y
    if (!translate(dx, dy)) {
        return 0
    }
    
    // Displacement in local coordinate system.
    var disp_local = to_local(dx - (x - x_original), dy - (y - y_original))
    // Porjected displacement in global coordinate system.
    var x_disp = to_global(disp_local.x, 0)
    var y_disp = to_global(0, disp_local.y)
    var mask_x = translate(x_disp.x, x_disp.y) ? 1 : 0
    var mask_y = translate(y_disp.x, y_disp.y) ? 1 : 0
    return (mask_y << 1) | mask_x
})

/**
 * Customized move_and_collide.
 * This method moves the instance as if we are playing a top-down-view game.
 * @self obj_kinematic
 * @param {Real} dx
 * @param {Real} dy
 * @return {Bool} Whether the movement is obstructed.
 */
move_collide = use_method(function(dx, dy) {
    if (obstructed_at(x, y)) {
        return true
    }
    var dist = point_distance(0, 0, dx, dy)
    if (dist == 0) {
        return false
    }
    
    var sqrt2 = sqrt(2)
    var x0 = x
    var y0 = y
    var ix = dx / dist
    var iy = dy / dist
    var dist_to_travel = dist
    while (dist_to_travel > 0) {
        var step = min(substep, dist_to_travel)
        if (!translate(step * ix, step * iy)) {
            dist_to_travel -= step
            continue
        }
        
        // The direct movement is obstructed.
        // Try to move in perpendicular direction (iy, -ix) and (-iy, ix).
        var moved = false // If not moved, the movement is obstructed.
        
        // We probe (ix, iy) ± k(iy, -ix) to step forward in perpendicular direction.
        // The maximum k is estimated by dist_to_travel * sqrt(2)
        // The coefficient sqrt(2) is empirical.
        var ub = max(dist_to_travel * sqrt2, 1)
        for (var k = 1; k <= ub; k++) {
            var x_dest = x + (ix + k * iy)
            var y_dest = y + (iy - k * ix)
            if (!obstructed_at(x_dest, y_dest)) {
                dist_to_travel -= point_distance(x, y, x_dest, y_dest)
                x = x_dest
                y = y_dest
                moved = true
                break
            }
            
            x_dest = x + (ix - k * iy)
            y_dest = y + (iy + k * ix)
            if (!obstructed_at(x_dest, y_dest)) {
                dist_to_travel -= point_distance(x, y, x_dest, y_dest)
                x = x_dest
                y = y_dest
                moved = true
                break
            }
        }
        
        if (!moved) {
            break
        }
    }
    
    return x == x0 && y == y0
})

/**
 * Customized move_and_slide.
 * This method moves the instance as if we are playing a platformer game.
 * It takes slopes into account.
 * @param {Real} dx
 * @param {Real} dy
 * @return {Bool} Whether the movement is obstructed.
 */
move_slide = use_method(function(dx, dy) {
    if (obstructed_at(x, y)) {
        return true
    }
    var dist = point_distance(0, 0, dx, dy)
    if (dist == 0) {
        return false
    }
    
    var udx = dx / dist
    var udy = dy / dist
    var dist_to_travel = dist
    while (dist_to_travel > 0) {
        var step = min(substep, dist_to_travel)
        // Displacement in local coordinate system.
        var disp_local = to_local(step * udx, step * udy)
        if (disp_local.y >= 0 && obstructed_at(x + downdir.x, y + downdir.y)) {
            // On floor.
            // Move only in local x direction.
            var proj_dx = to_global(disp_local.x, 0)
            var obstructed = move_collide(proj_dx.x, proj_dx.y)
            var x_before = x
            var y_before = y
            if (!translate(floor_snap * downdir.x, floor_snap * downdir.y)) {
                x = x_before
                y = y_before
            } else if (obstructed) {
                return true
            }
        } else {
            // Off floor
            if (translate_orthogonal(step * udx, step * udy) != 0) {
                return true
            }
        }
        dist_to_travel -= substep
    }
    return false
})

/**
 * Compute the actual driven displacement.
 * @param {Real} driver_dx
 * @param {Real} driver_dy
 * @return {Struct.Vector}
 */
compute_driven_displacement = use_method(function(driver_dx, driver_dy) {
    var driver_disp_local = to_local(driver_dx, driver_dy)
    if (driver_disp_local.x == 0) {
        //
    } else if (_driven_x == 0) {
        _driven_x = driver_disp_local.x
    } else if (sign(driver_disp_local.x) == sign(_driven_x)) {
        if (abs(driver_disp_local.x) <= abs(_driven_x)) {
            driver_disp_local.x = 0
        } else {
            var t = driver_disp_local.x
            _driven_x = driver_disp_local.x
            driver_disp_local.x -= _driven_x
        }
    } else {
        _driven_x += driver_disp_local.x
    }
    return to_global(driver_disp_local)
})

/**
 * Assuming the instance is placed at (x, y), check whether it collides with obstacles.
 * This method can be overriden in child object.
 * @param {Real} x
 * @param {Real} y
 * @return {Bool}
 */
obstructed_at = use_method(function(_x, _y) { return false })

/**
 * Default moving method serving as an interactive interface.
 * This method can be overriden in child object.
 * @param {Real} dx
 * @param {Real} dy
 */
move = translate
