extends Node

var config_handler : ConfigHandler

var loaded_data = {
	'configuration': null,
	'progress': null
}

var local_players: Array = [
	PlayerInfo.new(0, 0, true)
]

var websocket_players: Array = []

func _ready():
	_start_dependencies()
	_start_game()

func _start_dependencies():
	config_handler = ConfigHandler.new(self)

func _start_game():
	_load_configuration_data()
	config_handler.config_all(loaded_data.configuration)
	_load_progress_data()

func _load_configuration_data():
	var config_file = ConfigFile.new()
	var data_name = ProjectSettings.get_setting("game/data/configuration_data_name")
	var config_data_loaded = PersistentDataHandler.load_config(data_name)
	if config_data_loaded != null:
		loaded_data.configuration = config_data_loaded
	else:
		loaded_data.configuration = ConfigHandler.get_default_config()
		PersistentDataHandler.save_config(data_name, loaded_data.configuration)
	

func _load_progress_data():
	var data_name = ProjectSettings.get_setting("game/data/progress_data_name")
	if PersistentDataHandler.data_exists(data_name):
		pass
	else:
		PersistentDataHandler.save_data(data_name, loaded_data.progress)
