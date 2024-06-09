/**
 * @param {Real} t
 * @return {Real}
 */
function easing_linear(t) {
    return clamp(t, 0, 1)
}

/**
 * @param {Real} t
 * @return {Real}
 */
function easing_quintic(t) {
    t = clamp(t, 0, 1)
    return ((6 * t - 15) * t + 10) * t * t * t
}
