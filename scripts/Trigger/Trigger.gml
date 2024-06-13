/// Feather use syntax-errors

enum TriggerState {
    Inactive, Pending, Running, Finished,
}

global.triggered_index = 0

/**
 * Trigger base class.
 * @param {Real} index Trigger index.
 * @param {Id.Instance} [inst] Instance to bind with.
 */
function Trigger(index, inst = other) constructor {
    self.index = index
    self.inst = inst
    _state = TriggerState.Inactive
    
    /**
     * Trigger index.
     * @return {Real}
     */
    static get_index = function() { return index }
    
    /**
     * Trigger state.
     * @return {Enum.TriggerState}
     */
    static get_state = function() { return _state }
    
    /**
     * Callback when started.
     */
    static on_start = function() {}
    
    /**
     * Callback when running.
     */
    static on_update = on_start
    
    /**
     * Callback when finished.
     */
    static on_finish = on_start
    
    /**
     * Start the trigger.
     */
    static start = function() {
        if (_state == TriggerState.Inactive) {
            on_start()
            _state = TriggerState.Running
        }
    }
    
    /**
     * Trigger update behaviour.
     */
    static update = function() {
        if (_state == TriggerState.Running) {
            on_update()
        }
    }
    
    /**
     * Finish the trigger.
     */
    static finish = function() {
        if (_state == TriggerState.Running) {
            on_finish()
            _state = TriggerState.Finished
        }
    }
}

/**
 * Trigges executed in sequential order.
 * @param {Array<Struct>} children Child triggers.
 */
function TriggerSequence(children) constructor {
    self.children = children
    running_index = 0
    _state = TriggerState.Inactive
    
    /**
     * Get the index of current child trigger.
     * @return {Real}
     */
    static get_index = function() {
        return running_index < array_length(children) ?
            children[running_index].get_index() : -1
    }
    
    /**
     * Get trigger state.
     * @return {Enum.TriggerState}
     */
    static get_state = function() { return _state }
    
    /**
     * Start the trigger.
     */
    static start = function() {
        if (_state == TriggerState.Inactive) {
            _state = TriggerState.Running
            children[running_index].start()
        }
    }
    
    /**
     * Update behaviour.
     */
    static update = function() {
        if (_state == TriggerState.Running) {
            children[running_index].update()
            if (children[running_index].get_state() == TriggerState.Finished) {
                running_index++
                if (running_index < array_length(children)) {
                    children[running_index].start()
                } else {
                    _state = TriggerState.Finished
                }
            }
        }
    }
}

/**
 * Triggers executed concurrently.
 * The indices of child triggers are ignored.
 * @param {Real} index Trigger index.
 * @param {Array<Struct>} children Child triggers.
 */
function TriggerGroup(index, children) constructor {
    self.index = index
    self.children = children
    _state = TriggerState.Inactive
    
    /**
     * Trigger index.
     */
    static get_index = function() { return index }
    
    /**
     * Trigger state.
     */
    static get_state = function() { return _state }
    
    /**
     * Start the trigger.
     */
    static start = function() {
        if (_state == TriggerState.Inactive) {
            var n = array_length(children)
            for (var i = 0; i < n; i++) {
                children[i].start()
            }
            _state = TriggerState.Running
        }
    }
    
    /**
     * Update behaviour.
     */
    static update = function() {
        if (_state == TriggerState.Running) {
            var finished = true
            var n = array_length(children)
            for (var i = 0; i < n; i++) {
                children[i].update()
                if (children[i].get_state() != TriggerState.Finished) {
                    finished = false
                }
            }
            if (finished) {
                _state = TriggerState.Finished
            }
        }
    }
}

/**
 * Delayed trigger decorator.
 * @param {Real} delay Seconds to delay.
 * @param {Struct} trigger Trigger to decorate.
 */
function DelayedTrigger(delay, trigger) constructor {
    self.delay = delay
    self.trigger = trigger
    pending = false
    
    /**
     * Trigger index.
     */
    static get_index = function() { return trigger.get_index() }
    
    /**
     * Trigger state.
     */
    static get_state = function() {
        return pending ? TriggerState.Pending : trigger.get_state()
    }
    
    /**
     * Start the trigger.
     */
    static start = function() {
        if (get_state() == TriggerState.Inactive) {
            pending = true
            call_later(delay, time_source_units_seconds, function() {
                pending = false
                trigger.start()
            })
        }
    }
    
    /**
     * Update behaviour.
     */
    static update = function() {
        if (get_state() == TriggerState.Running) {
            trigger.update()
        }
    }
}
