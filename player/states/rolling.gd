extends PlayerState
# rolling friction factor
const r_friction_factor := 0.5

func _enter(host: Player, delta):
	host.character.rotation = 0
	host.reset_snap()

func _physics_update(host: Player, delta):
	
	if not host.is_grounded:
		finish("OnAir")
		return
	
	if host.is_jump_btn_just_pressed():
		finish(host.jump())
		return
	
	var values = host.physics_values()
	var ground_angle = host.ground_angle
	
	#prints(Utils.is_sign_opposite(host.input_axis.x, host.ground_vel), host.ground_vel)
	if Utils.is_sign_opposite(host.input_axis.x, host.ground_vel):
		host.handle_acc_n_dec()
	elif host.input_axis.x != 0:
		host.handle_friction(r_friction_factor)
	
	host.handle_slope(values.slp)
	host.handle_ground_vel()
	
	if abs(host.ground_vel) < host.MOVING_LIMIT:
		finish(host.MOVING)
		return
	
	if host.is_pushing_wall():
		finish(host.IDLE)
		return
	
	if not host.can_fall():
		host.snap_ground()


func _update(host: Player, delta):
	var animator := host.animator()
	var ground_angle = host.ground_angle
	
	host.set_facing(host.input_axis.x as int)
	
	animator.set("parameters/main_transition/current", host.MainStates.GROUND)
	animator.set("parameters/ground_transition/current", host.GroundStates.MOVING)
	animator.set("parameters/ground_moving_state/current", host.MovingAnims.ROLLING)
	
	var abs_vel = abs(host.ground_vel)
	var anim_speed : float = 1
	
	var main_value := 8.0
	anim_speed = max(-(main_value * delta - abs_vel * (delta * 0.5)), 1.5) - 0.5
	
	animator.set("parameters/ground_moving_time_scale/scale", anim_speed)
