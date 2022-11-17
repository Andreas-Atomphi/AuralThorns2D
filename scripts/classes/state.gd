class_name State
extends Node

signal finished(next_state)
signal deferred(next_state)

export var _physics_updating : bool = true setget set_physics_update, is_physics_updating
export var _updating : bool = true setget set_update, is_updating

# Finish current state and change to "next_state" parameter  
func finish(next_state:String) -> void:
	emit_signal("finished", next_state)

# Queue next_state to change when current frame ends
func defer(next_state:String) -> void:
	emit_signal("deferred", next_state)


func set_physics_update(p_value: bool) -> void:
	_physics_updating = p_value


func is_physics_updating() -> bool:
	return _physics_updating


func set_update(p_value: bool) -> void:
	_updating = p_value


func is_updating() -> bool:
	return _updating


func _enter(host, previous_state: String) -> void:
	pass


func _exit(host, next_state : String) -> void:
	pass


func _update(host, delta) -> void:
	pass


func _physics_update(host, delta) -> void:
	pass

