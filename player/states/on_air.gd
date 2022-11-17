extends PlayerState


func _enter(host: Player, previous_state:String):
	host.rotation = 0.0
	host.erase_snap()
	if host.is_anim_rolling():
		host.character.rotation = 0.0

func _exit(host: Player, next_state:String):
	host.airbone = false

func _physics_update(host:Player, delta: float):
	var values := host.physics_values()
	
	if host.input_axis.x != 0:
		host.vel.x = move_toward(
			host.vel.x,
			values.top_spd * host.input_axis.x,
			values.air_acc * delta
		)
	
	if host.vel.y > -265.0 and host.vel.y < 0:
		host.vel.x = move_toward(host.vel.x, 0, host.vel.x * delta)
	
	host.vel.y += values.grv * delta
	
	if host.vel.y > 960:
		host.vel.y = 960
	
	if host.is_grounded:
		finish(host.MOVING)
		host.reacquire_on_floor()
		return
	

func _s_input(host: Player, event:InputEvent, actions:IGActions):
	var controllable_height = 128
	if host.is_jump_btn_just_released() and host.vel.y < -controllable_height:
		host.vel.y *= 0.75


func _update(host: Player, delta:float):
	var animator := host.animator()
	host.character.rotation = move_toward(host.character.rotation, 0.0, TAU * delta)
	host.set_facing(host.input_axis.x as int)
	var air_state: int
	if host.airbone == true:
		air_state = host.AirStates.AIRBONE
	if host.airbone:
		animator.set("parameters/main_transition/current", host.MainStates.AIR)
		animator.set("parameters/air_state/current", air_state)
