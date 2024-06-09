/**
 * @param {Real} [x]
 * @param {Real} [y]
 */
function Vector(_x = 0, _y = 0) constructor {
    x = _x
    y = _y
    
    /**
     * @return {Real}
     */
    static magnitude = function() {
        return point_distance(0, 0, x, y)
    }
    
    /**
     * @return {Real}
     */
    static direktion = function() {
        return point_direction(0, 0, x, y)
    }
    
    /**
     * @return {Struct.Vector}
     */
    static normalize = function() {
        var mag = magnitude()
        return new Vector(x / mag, y / mag)
    }
    
    /**
     * @return {Struct.Vector}
     */
    static negative = function() {
        return new Vector(-x, -y)
    }
    
    /**
     * @param {Real} deg
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
     * @param {Real} x
     * @param {Real} y
     * @return {Struct.Vector}
     */
    static add = function(_x, _y) {
        return new Vector(x + _x, y + _y)
    }
    
    /**
     * @param {Real} x
     * @param {Real} y
     * @return {Struct.Vector}
     */
    static sub = function(_x, _y) {
        return new Vector(x - _x, y - _y)
    }
    
    /**
     * @param {Real} scalar
     * @return {Struct.Vector}
     */
    static mul = function(scalar) {
        return new Vector(x * scalar, y * scalar)
    }
    
    /**
     * @return {Struct.Vector}
     */
    static negative_ = function() {
        x = -x
        y = -y
        return self
    }
    
    /**
     * @return {Struct.Vector}
     */
    static normalize_ = function() {
        var mag = magnitude()
        x /= mag
        y /= mag
        return self
    }
    
    /**
     * @param {Real} x
     * @param {Real} y
     * @return {Struct.Vector}
     */
    static add_ = function(_x, _y) {
        x += _x
        y += _y
        return self
    }
    
    /**
     * @param {Real} x
     * @param {Real} y
     * @return {Struct.Vector}
     */
    static sub_ = function(_x, _y) {
        x -= _x
        y -= _y
        return self
    }
    
    /**
     * @param {Real} scalar
     * @return {Struct.Vector}
     */
    static mul_ = function(scalar) {
        x *= scalar
        y *= scalar
        return self
    }
    
    /**
     * @param {Real} deg
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
