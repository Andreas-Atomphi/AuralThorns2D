class_name AvailableCharacterInfos
extends Object

export var character_name: String
export var character_id: int
export(String, FILE, "*.png") var save_select_icon
export(String, FILE, "*.tscn") var character_path

func _init(
	p_character_name:String,
	p_character_id:int,
	p_save_select_icon:String,
	p_character_path:String
) -> void:
	character_name = p_character_name
	character_id = p_character_id
	save_select_icon = p_save_select_icon
	character_path = p_character_path
