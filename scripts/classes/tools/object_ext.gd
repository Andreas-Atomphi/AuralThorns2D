class_name ObjectExt
extends Object

var instanced = false setget readonly

func readonly(val) -> void:
	assert(not instanced, "Cannot set a value of readonly var")
