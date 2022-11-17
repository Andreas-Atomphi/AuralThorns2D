class_name IGActions
extends ObjectExt


static func available_actions():
	return {
		up = "ig_up",
		left = "ig_left",
		down = "ig_down",
		right = "ig_right",
		j1 = "ig_j1",
		j2 = "ig_j2",
		j3 = "ig_j3",
		s = "ig_s",
	}

var _index: int

var up: String
var left: String
var down: String 
var right: String
var j1: String
var j2: String
var j3: String
var s: String

func _init(p_index:int):
	_index = p_index
	var actions = get_script().available_actions()
	#print(get_stack())
	for action in actions:
		set(action, load("res://scripts/classes/utils.gd").convert_action(actions[action], p_index))
