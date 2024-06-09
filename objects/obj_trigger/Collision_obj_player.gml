if (preindex == 0 || global.triggered_index == preindex) {
    global.triggered_index = index
    if (is_callable(on_trigger)) {
        on_trigger()
    }
    instance_destroy()
}