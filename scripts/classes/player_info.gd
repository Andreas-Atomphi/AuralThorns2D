class_name PlayerInfo
extends Object
# Player information between menus and in-game scene

var _character_id : int setget set_character_id, get_character_id
var _player_id : int setget set_player_id, get_player_id
var _is_human : bool = false setget , is_human


func _init(p_player_id: int, p_character_id: int = 0, p_is_human:= false):
	_character_id = p_character_id
	_player_id = p_player_id
	_is_human = p_is_human


func set_character_id(val : int) -> void: _character_id = val
func get_character_id() -> int: return _character_id

func set_player_id(val : int) -> void: _player_id = val
func get_player_id() -> int: return _player_id

func is_human() -> bool: return _is_human
