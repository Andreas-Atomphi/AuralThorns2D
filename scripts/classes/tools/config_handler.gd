class_name ConfigHandler

var _owner

func _init(p_owner: Node):
	_owner = p_owner

func config_all(config:Dictionary):
	_config_input(config["input"])

func _config_input(input:Dictionary):
	var i = 0
	for item in input:
		var value = input[item]
		for config in value:
			var action = config + "_%s" % i
			var event = InputEventKey.new()
			event.scancode = value[config]
			if InputMap.action_has_event(action, event):
				InputMap.action_erase_event(action, event)
			InputMap.action_add_event(action, event)
		i += 1


# Static Functions
static func get_default_config(): 
	return {
		input = _default_input()
	}

static func _default_input(): 
	return {
		"local_p1": {
			"ig_up" : KEY_W,
			"ig_left" : KEY_A,
			"ig_right" : KEY_D,
			"ig_down" : KEY_S,
			"ig_j1" : KEY_J,
			"ig_j2" : KEY_K,
			"ig_j3" : KEY_L,
			"ig_s" : KEY_I,
		},
		"local_p2": {
			"ig_up" : KEY_UP,
			"ig_left" : KEY_LEFT,
			"ig_right" : KEY_RIGHT,
			"ig_down" : KEY_DOWN,
			"ig_j1" : KEY_KP_1,
			"ig_j2" : KEY_KP_2,
			"ig_j3" : KEY_KP_3,
			"ig_s" : KEY_KP_5,
		}
	}
