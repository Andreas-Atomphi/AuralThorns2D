class_name InputGameData
extends JSONAble

var ig_up
var ig_left
var ig_right
var ig_down
var ig_j1
var ig_j2
var ig_j3
var ig_s

func _init(
	p_ig_up = KEY_W,
	p_ig_left = KEY_A,
	p_ig_right = KEY_D,
	p_ig_down = KEY_S,
	p_ig_j1 = KEY_J,
	p_ig_j2 = KEY_K,
	p_ig_j3 = KEY_L,
	p_ig_s = KEY_I
):
	ig_up = p_ig_up
	ig_left = p_ig_left
	ig_right = p_ig_right
	ig_down = p_ig_down
	ig_j1 = p_ig_j1
	ig_j2 = p_ig_j2
	ig_j3 = p_ig_j3
	ig_s = p_ig_s

func to_dictionary() -> Dictionary:
	return {
		"ig_up" : ig_up,
		"ig_left" : ig_left,
		"ig_right" : ig_right,
		"ig_down" : ig_down,
		"ig_j1" : ig_j1,
		"ig_j2" : ig_j2,
		"ig_j3" : ig_j3,
		"ig_s" : ig_s,
	}

static func from_dictionary(dict:Dictionary):
	return load("res://scripts/classes/input_game_data.gd").new(
		dict["ig_up"],
		dict["ig_left"],
		dict["ig_right"],
		dict["ig_down"],
		dict["ig_j1"],
		dict["ig_j2"],
		dict["ig_j3"],
		dict["ig_s"]
	)
