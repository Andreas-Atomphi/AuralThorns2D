tool
class_name StateMachine
extends Node

signal state_changed(previous_state_name, current_state_name)

const ERR_TEXTS = {
	ERR_DOES_NOT_EXIST: "Error: state %s was not found in current context",
	ERR_INVALID_DATA: "Error: node %s is not a state"
}

export(NodePath) var initial_state : NodePath = @"Idle"

var state : PlayerState
var state_queued

var _host

func _ready():pass


func change_if_queued() -> void:
	if state_queued == null: return
	change_state(state_queued.name)

# Queue a state to change, if not change by any signal emission, this will change
func defer_state(p_name:NodePath) -> void:
	assert(has_node(p_name), ERR_TEXTS[ERR_DOES_NOT_EXIST] % p_name)
	state_queued = p_name


func change_state(p_name:NodePath) -> void:
	if p_name == state.name: return
	assert(has_node(p_name), ERR_TEXTS[ERR_DOES_NOT_EXIST] % p_name)
	
	var previous_state := state
	
	_unset_state(p_name)
	previous_state._exit(_host, p_name)
	
	_setup_state(p_name)
	state._enter(_host, previous_state.name)
	
	emit_signal("state_changed", previous_state.name, state.name)


func insert_state(p_state:State, p_name = null):
	if has_node(p_name):
		get_node(p_name).queue_free()
	
	if p_name != null and p_name is String:
		state.name = p_name
	
	add_child(state)


func remove_state(p_state:NodePath):
	if !has_node(p_state):
		push_error("State does not exist")
		return
	
	get_node(p_state).queue_free()


func get_state(p_name:NodePath) -> State:
	assert(has_node(p_name), ERR_TEXTS[ERR_ALREADY_EXISTS] % p_name)
	
	var to_return = get_node(p_name)
	assert(to_return is State, ERR_TEXTS[ERR_INVALID_DATA] % p_name)
	
	return get_node(p_name) as State


func _host_ready(p_host):
	_host = p_host
	_setup_state(initial_state)


func _setup_state(state_name:NodePath):
	if !has_node(state_name):
		return
	state = get_node(state_name)
	state.connect("finished", self, "change_state", [], CONNECT_ONESHOT)
	state.connect("deferred", self, "defer_state", [], CONNECT_ONESHOT)


func _unset_state(state_name:NodePath):
	if !has_node(state_name):
		return
	
	var previous_state = get_node(state_name)
	
	if previous_state.is_connected("finished", self, "change_state"):
		previous_state.disconnect("finished", self, "change_state")
	
	if previous_state.is_connected("deferred", self, "defer_state"):
		previous_state.disconnect("deferred", self, "defer_state")


func _fsm_physics_update(delta):
	if state.is_physics_updating():
		state._physics_update(_host, delta)


func _fsm_update(delta):
	if state.is_updating():
		state._update(_host, delta)


func _fsm_input(event:InputEvent, actions:IGActions):
	state._s_input(_host, event, actions)


func _get_configuration_warning():
	if get_child_count() < 1:
		return "Need at least one state"
	
	for child in get_children():
		if not child is State:
			return "All StateMachine childrens has to be a State type"
	
	return ""
