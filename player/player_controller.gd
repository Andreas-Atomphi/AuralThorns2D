extends Node
class_name PlayerController

var offline_index
var player: Player setget set_player, get_player
var input_actions :Dictionary

# artificial_controller, can be an ai or an websocket controller
var a_controller setget set_a_controller

func _ready():
	set_process_unhandled_input(false)

func _unhandled_input(event):
	player.p_input(event, input_actions)

func activate_human_player(p_player : Player, p_offline_index: int):
	set_player(p_player)
	offline_index = p_offline_index
	input_actions = Utils.get_ig_actions(offline_index)
	set_process_unhandled_input(true)

func set_player(val : Player) -> void:
	if val == null: return
	player = val

func get_player() -> Player: return player

func set_a_controller(val) -> void:
	a_controller = val
	set_process_unhandled_input(false)
