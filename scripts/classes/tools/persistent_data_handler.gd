class_name PersistentDataHandler
extends Object

const DATA_PATH = "user://%s"

static func save_config(data_name:String, data:Dictionary) -> int:
	var cfile = ConfigFile.new()
	for section_name in data:
		# Section of config file
		var section_configs = data[section_name]
		# Configuration values of configuration file
		for config_name in section_configs:
			var config_value = section_configs[config_name]
			#print(section_name, config_name, config_value)
			cfile.set_value(section_name, config_name, config_value)
	var err = cfile.save(DATA_PATH % data_name)
	if err != OK:
		return err
	return OK

static func load_config(data_name:String):
	var cfile = ConfigFile.new()
	var err = cfile.load(DATA_PATH % data_name)
	if err != OK or cfile.get_sections().empty():
		return
	var config_data := {}
	for section_key in cfile.get_sections():
		var section_data = {}
		for config_key in cfile.get_section_keys(section_key):
			section_data[config_key] = cfile.get_value(section_key, config_key)
		config_data[section_key] = section_data
	return config_data

static func save_data(data_name: String, data:Dictionary) -> int:
	var file = File.new()
	file.open(DATA_PATH % data_name, File.WRITE)
	if !file.is_open():
		return ERR_CANT_OPEN
	var json_data = to_json(data)
	file.store_line(json_data)
	file.close()
	return OK


static func load_data(data_name: String):
	var file = File.new()
	file.open(DATA_PATH % data_name, File.READ)
	var loaded_data:String = file.get_line()
	var decoded_data = parse_json(loaded_data)
	file.close()
	return decoded_data


static func data_exists(data_name: String):
	var file = File.new()
	if !file.file_exists(DATA_PATH % data_name):
		return false
	# Check if file is empty
	file.open(DATA_PATH % data_name, File.READ)
	if file.get_line().empty():
		return false
	# Close file if it's open
	if file.is_open():
		file.close()
	return true
