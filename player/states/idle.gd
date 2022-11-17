extends PlayerState

func _enter(host:Player, prev_state):
	host.ground_vel = 0
	host.vel = Vector2.ZERO
	host.reset_snap()

func _physics_update(host:Player, delta):
	if not host.is_grounded:
		finish(host.ON_AIR)
		return
	
	if host.is_jump_btn_just_pressed():
		finish(host.jump())
		return
	
	var values = host.physics_values()
	
	host.handle_friction()
	host.handle_slope(values.slp)
	if (
		(abs(host.ground_vel) >= host.IDLE_LIMIT or host.input_axis.x != 0)
		and not host.is_pushing_wall()
	):
		finish(host.MOVING)
		return
	
	host.ground_vel = 0.0
	

func _update(host:Player, delta:float):
	var animator := host.animator()
	var anim_speed : float = 1.0
	
	var current_anim_state = host.StoppedAnims.IDLE
	if host.is_pushing_wall():
		current_anim_state = host.StoppedAnims.PUSHING
	
	animator.set("parameters/main_transition/current", host.MainStates.GROUND)
	animator.set("parameters/ground_transition/current", host.GroundStates.STOPPED)
	animator.set("parameters/stopped_state/current", current_anim_state)
	animator.set("parameters/ground_moving_time_scale/scale", anim_speed)
