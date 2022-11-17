extends PlayerState

func _enter(host: Player, delta):
	host.reset_snap()

func _exit(host: Player, delta):
	pass

func _physics_update(host: Player, delta):
	
	if not host.is_grounded or host.can_fall():
		finish(host.ON_AIR)
		return
	
	if host.is_jump_btn_just_pressed():
		finish(host.jump())
		return
	
	var values = host.physics_values()
	var ground_angle = host.ground_angle
	
	if host.input_axis.x != 0:
		host.handle_acc_n_dec()
	else:
		host.handle_friction()
	
	if host.input_axis.y > 0 and abs(host.ground_vel) >= host.MOVING_LIMIT:
		finish(host.ROLLING)
		return
	
	host.handle_slope(values.slp)
	host.handle_ground_vel()
	
	if not host.can_fall():
		host.snap_ground()
	
	if (
		(abs(host.ground_vel) < host.IDLE_LIMIT and host.input_axis.x == 0)
		or host.is_pushing_wall()
	):
		finish(host.IDLE)
		return


func _update(host: Player, delta):
	var animator := host.animator()
	var ground_angle = host.ground_angle
	
	host.set_facing(host.input_axis.x as int)
	
	var target_angle = -Utils.collider_normal_to_angle(host.character.ray)
	host.rotate_sprite_to_ground(target_angle)
	
	animator.set("parameters/main_transition/current", host.MainStates.GROUND)
	animator.set("parameters/ground_transition/current", host.GroundStates.MOVING)
	
	var walking_vel = 360
	var jogging_vel = 490
	var running_vel = 630
	var max_speed_vel = 960
	
	var moving_anims := host.MovingAnims
	var abs_vel = abs(host.ground_vel)
	var current_moving_anim : int = (
		moving_anims.WALKING if abs_vel < walking_vel
		else moving_anims.JOGGING if abs_vel >= walking_vel and abs_vel < jogging_vel
		else moving_anims.RUNNING if abs_vel >= jogging_vel and abs_vel < running_vel
		else moving_anims.MAX_SPEED_RUNNING
	)
	
	var anim_speed : float = 1
	
	var main_value := 8.0
	anim_speed = max(-(main_value * delta - abs_vel * (delta * 0.5)), 1.5) - (
		0.5 if current_moving_anim != moving_anims.WALKING
		else 0.0
	)
	
	animator.set("parameters/ground_moving_state/current", current_moving_anim)
	animator.set("parameters/ground_moving_time_scale/scale", anim_speed)
