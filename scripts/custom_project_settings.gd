extends EditorScript
tool

func _run():
	for i in range(1, 4):
		InputMap.add_action("ig_up_%d" % i)
		InputMap.add_action("ig_left_%d" % i)
		InputMap.add_action("ig_right_%d" % i)
		InputMap.add_action("ig_down_%d" % i)
		InputMap.add_action("ig_j1_%d" % i)
		InputMap.add_action("ig_j2_%d" % i)
		InputMap.add_action("ig_j3_%d" % i)
		InputMap.add_action("ig_s_%d" % i)

func add_multiple_property_infos(val : Array) -> void:
	for i in val:
		if ProjectSettings.has_setting(i["name"]): continue
		ProjectSettings.add_property_info(i)
		ProjectSettings.save()
