tool
extends Node2D
class_name Character

var values : CharacterPhysicsValues
onready var animator : AnimationTree = $Animator
onready var skin : AnimatedSprite = $Skin
onready var ray : RayCast2D = $RayCast2D


func _get_property_list():
	var props = []
	
	props.append({
		"name": "values",
		"type": typeof(Resource),
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "CharacterPhysicsValues"
	})
	
	return props
