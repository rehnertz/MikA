event_inherited()
movement_speed = 150
max_fall_speed = 450
grav = 1000
face = 1
jump_speeds = [425, 350]
jump_level = 1
box = true

/**
 * Kill the player.
 * @self obj_player
 */
kill = use_method(function() {
    show_message("Player killed")
    instance_destroy()
})

/**
 * Assuming the instance is placed at (x, y), check whether it collides with obstacles.
 * @self obj_player
 * @param {Real} x
 * @param {Real} y
 * @return {Bool}
 */
obstructed_at = use_method(function(_x, _y) {
    return cast_mask(_x, _y, obj_block) ||
        cast_mask(_x, _y, obj_platform, is_beneath)
})

move = move_slide