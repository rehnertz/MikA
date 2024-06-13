/// Feather use syntax-errors

/**
 * Identification on [0, 1].
 * @param {Real} t
 * @return {Real}
 */
function easing_linear(t) {
    return clamp(t, 0, 1)
}

/**
 * Inerpolation function on [0, 1] with slow ends and fast middle.
 * This is a quintic polynomial: f(t) = 6t^5 - 15t^4 + 10t^3.
 * @param {Real} t
 * @return {Real}
 */
function easing_quintic(t) {
    t = clamp(t, 0, 1)
    return ((6 * t - 15) * t + 10) * t * t * t
}
