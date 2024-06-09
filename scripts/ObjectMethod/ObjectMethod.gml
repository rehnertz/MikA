#macro use_method _method_wrapper(_GMFILE_)

global._method_key = undefined

/**
 * @ignore
 * @param {String} gmfile
 */
function _method_wrapper(gmfile) {
    global._method_key = gmfile
    return _use_method
}

/**
 * Declare an object method.
 * All instances of current object will have the same function reference.
 * This function has no instance bound, i.e. method_get_self(·) == undefined.
 * This function can only be used in create event and called in consistant order.
 * @ignore
 * @param {Function} fn Method definition.
 * @return {Function}
 */
function _use_method(fn) {
    // object_index ↦ fn[] (methods defined in object_index)
    static fn_records = ds_map_create()
    // object_index ↦ fn_index (current method index)
    static indices = ds_map_create()
    
    if (event_type != ev_create) {
        show_error("Object methods can only be declared in create event.", false)
    }
    
    var key = global._method_key
    var idx = indices[? key]
    if (idx == undefined) {
        idx = 0
        indices[? key] = idx
    }
    
    var fn_list = fn_records[? key]
    if (fn_list == undefined) {
        fn_list = []
        fn_records[? key] = fn_list
    }
    
    var n = array_length(fn_list)
    var cached_fn
    if (idx >= n) {
        cached_fn = method(undefined, fn)
        array_push(fn_list, cached_fn)
        indices[? key]++
    } else {
        cached_fn = fn_list[idx]
    }
    delete fn
    return cached_fn
}
