extends PlayerState

func _enter(host:Player, prev_state):
	host.ground_vel = 0
	host.vel = Vector2.ZERO

func _physics_update(host:Player, delta):
	var values = host.physics_values()
	
	host.handle_friction()
	host.handle_slope(values.slp)
	
	if (
		abs(host.ground_vel) >= host.IDLE_LIMIT
		or host.input_axis.x != 0
	):
		finish("Walking")


func _update(host:Player, delta:float):
	var animator := host.animator()
	var anim_speed : float = 1.0
	
	animator.set("parameters/main_transition/current", host.MainStates.GROUND)
	animator.set("parameters/ground_transition/current", host.GroundStates.STOPPED)
	animator.set("parameters/stopped_state/current", host.StoppedAnims.IDLE)
	animator.set("parameters/ground_moving_time_scale/scale", anim_speed)
