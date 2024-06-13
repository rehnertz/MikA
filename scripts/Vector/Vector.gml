/// Feather use syntax-errors

/**
 * A 2D vector.
 * @param {Real} [x]
 * @param {Real} [y]
 */
function Vector(_x = 0, _y = 0) constructor {
    x = _x
    y = _y
    
    /**
     Get the magnitude (length) of the vector.
     * @return {Real}
     */
    static magnitude = function() {
        return point_distance(0, 0, x, y)
    }
    
    /**
     * Get the direction (in degree) of the vector.
     * @return {Real}
     */
    static direktion = function() {
        return point_direction(0, 0, x, y)
    }
    
    /**
     * Get a copy of normalized vector.
     * @return {Struct.Vector}
     */
    static normalize = function() {
        var mag = magnitude()
        return new Vector(x / mag, y / mag)
    }
    
    /**
     * Get a copy of the vector in anti-direction.
     * @return {Struct.Vector}
     */
    static negative = function() {
        return new Vector(-x, -y)
    }
    
    /**
     * Get a copy of rotated vector.
     * @param {Real} deg Degrees to rotate anti-clockwise.
     * @return {Struct.Vector}
     */
    static rotate = function(deg) {
        var c = dcos(deg)
        var s = dsin(deg)
        return new Vector(
            dot_product(c, s, x, y),
            dot_product(-s, c, x, y)
        )
    }
    
    /**
     * Get a copy of added vector.
     * @param {Real, Struct.Vector} x_or_vec
     * @param {Real} [y]
     * @return {Struct.Vector}
     */
    static add = function(x_or_vec, _y = undefined) {
        var add_x
        var add_y
        if (is_instanceof(x_or_vec, Vector)) {
            add_x = x_or_vec.x
            add_y = x_or_vec.y
        } else {
            add_x = x_or_vec
            add_y = _y
        }
        return new Vector(x + add_x, y + add_y)
    }
    
    /**
     * Get a copy of subtracted vector.
     * @param {Real, Struct.Vector} x_or_vec
     * @param {Real} [y]
     * @return {Struct.Vector}
     */
    static sub = function(x_or_vec, _y = undefined) {
        var sub_x
        var sub_y
        if (is_instanceof(x_or_vec, Vector)) {
            sub_x = x_or_vec.x
            sub_y = x_or_vec.y
        } else {
            sub_x = x_or_vec
            sub_y = _y
        }
        return new Vector(x - sub_x, y - sub_y)
    }
    
    /**
     * Get a copy of multiplied vector.
     * @param {Real, Struct.Vector} x_or_scalar_or_vec
     * @param {Real} [y]
     * @return {Struct.Vector}
     */
    static mul = function(x_or_scalar_or_vec, _y = undefined) {
        var mul_x
        var mul_y
        if (is_instanceof(x_or_scalar_or_vec, Vector)) {
            mul_x = x_or_scalar_or_vec.x
            mul_y = x_or_scalar_or_vec.y
        } else if (_y == undefined) {
            mul_x = x_or_scalar_or_vec
            mul_y = x_or_scalar_or_vec
        } else {
            mul_x = x_or_scalar_or_vec
            mul_y = _y
        }
        return new Vector(x * mul_x, y * mul_y)
    }
    
    /**
     * Reverse the direction of the vector.
     * @return {Struct.Vector}
     */
    static negative_ = function() {
        x = -x
        y = -y
        return self
    }
    
    /**
     * Normalize the vector.
     * @return {Struct.Vector}
     */
    static normalize_ = function() {
        var mag = magnitude()
        x /= mag
        y /= mag
        return self
    }
    
    /**
     * Add a vector.
     * @param {Real, Struct.Vector} x_or_vec
     * @param {Real} [y]
     * @return {Struct.Vector}
     */
    static add_ = function(x_or_vec, _y = undefined) {
        var add_x
        var add_y
        if (is_instanceof(x_or_vec, Vector)) {
            add_x = x_or_vec.x
            add_y = x_or_vec.y
        } else {
            add_x = x_or_vec
            add_y = _y
        }
        x += add_x
        y += add_y
        return self
    }
    
    /**
     * Subtract a vector.
     * @param {Real, Struct.Vector} x_or_vec
     * @param {Real} [y]
     * @return {Struct.Vector}
     */
    static sub_ = function(x_or_vec, _y = undefined) {
        var sub_x
        var sub_y
        if (is_instanceof(x_or_vec, Vector)) {
            sub_x = x_or_vec.x
            sub_y = x_or_vec.y
        } else {
            sub_x = x_or_vec
            sub_y = _y
        }
        x -= sub_x
        y -= sub_y
        return self
    }
    
    /**
     * Multiply a vector or scalar.
     * @param {Real, Struct.Vector} x_or_scalar_or_vec
     * @param {Real} [y]
     * @return {Struct.Vector}
     */
    static mul_ = function(x_or_scalar_or_vec, _y = undefined) {
        var mul_x
        var mul_y
        if (is_instanceof(x_or_scalar_or_vec, Vector)) {
            mul_x = x_or_scalar_or_vec.x
            mul_y = x_or_scalar_or_vec.y
        } else if (_y == undefined) {
            mul_x = x_or_scalar_or_vec
            mul_y = x_or_scalar_or_vec
        } else {
            mul_x = x_or_scalar_or_vec
            mul_y = _y
        }
        x *= mul_x
        y *= mul_y
        return self
    }
    
    /**
     * Rotate the vector.
     * @param {Real} deg Degrees to rotate anti-clockwise.
     * @return {Struct.Vector}
     */
    static rotate_ = function(deg) {
        var c = dcos(deg)
        var s = dsin(deg)
        var _x = x
        var _y = y
        x = dot_product(c, s, _x, _y)
        y = dot_product(-s, c, _x, _y)
        return self
    }
}
