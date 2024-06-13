/// Feather use syntax-errors

#macro use_method _use_method(_GMFILE_, _GMLINE_)

/**
 * Define an object method.
 * Every instances of current object will share the same method reference.
 * This method is not bound to any instances, i.e. method_get_self(fn) === undefined.
 * Usually this method should only be called in create event.
 * @param {String} gmfile
 * @param {Real} gmline
 */
function _use_method(gmfile, gmline) {
    static key = undefined
    key = $"{gmfile}:{gmline}"
    
    /**
     * @param {Function} fn
     * @return {Function}
     */
    static impl = function(fn) {
        static meta = static_get(_use_method)
        static storage = {}
        
        var key = meta.key
        var store = storage[$ key]
        if (store == undefined) {
            store = method(undefined, fn)
            storage[$ key] = store
        }
        return store
    }
    
    return impl
}
