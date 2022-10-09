tool
class_name InitialPlayerSpawner
extends Node2D

# Add players to the scene

onready var players_container: Node = $Players

func _ready():
	if Engine.editor_hint: return
	for i in get_node("/root/Global").local_players.size():
		var player_controller := PlayerController.new()
		var player_scene :PackedScene = load("res://player/player.tscn")
		var player : Player = player_scene.instance()
		var player_info : PlayerInfo = get_node("/root/Global").local_players[i]
		player.global_position = global_position
		players_container.add_child(player_controller)
		player_controller.add_child(player)
		if not player_info.is_human(): continue
		player_controller.activate_human_player(player, i)

func _draw():
	if Engine.editor_hint:
		_editor_draw()

func _editor_draw():
	var rect_size = Vector2(18, 39)
	var rect_position = Vector2(-rect_size.x * 0.5, -rect_size.y)
	var polygons_points = [
		Vector2(-rect_size.x * 0.5, -rect_size.y * 0.5),
		Vector2(-rect_size.x * 0.5, rect_size.y * 0.25),
		Vector2(0, rect_size.y * 0.5),
		Vector2(rect_size.x * 0.5, rect_size.y * 0.25),
		Vector2(rect_size.x * 0.5, -rect_size.y * 0.5),
	]
	draw_polygon(polygons_points, [Color(0x00_cc_aa_aa)], [], null, null, true)
