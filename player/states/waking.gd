extends PlayerState

func _physics_update(host: Player, delta):
	var values = host.physics_values()
	var ground_angle = host.ground_angle
	
	if abs(host.ground_vel) < host.IDLE_LIMIT:
		finish("Idle")
	
	if host.input_axis.x == 0:
		host.handle_friction()
	else:
		host.handle_acceleration()
	
	host.handle_slope(values.slp)
	host.handle_ground_vel()
	host.snap_ground()


func _update(host: Player, delta):
	var animator := host.animator()
	var ground_angle = host.ground_angle
	
	var target_angle = -Utils.collider_angle(host.character.ray)
	var min_to_rotate_sprite := deg2rad(22.5)
	
	host.facing = host.input_axis.x as int
	
	if abs(ground_angle) < min_to_rotate_sprite:
		host.character.rotation = move_toward(host.character.rotation, 0.0, delta * TAU)
	else:
		host.character.rotation = lerp_angle(host.character.rotation, target_angle, delta * 2 * TAU)
	
	animator.set("parameters/main_transition/current", host.MainStates.GROUND)
	animator.set("parameters/ground_transition/current", host.GroundStates.MOVING)
	
	var abs_vel = abs(host.ground_vel)
	
	var walking_vel = 260
	var jogging_vel = 390
	var running_vel = 560
	var max_speed_vel = 960
	
	var moving_anims := host.MovingAnims
	var current_moving_anim : int = (
		moving_anims.WALKING if abs_vel < walking_vel
		else moving_anims.JOGGING if abs_vel >= walking_vel and abs_vel < jogging_vel
		else moving_anims.RUNNING if abs_vel >= jogging_vel and abs_vel < running_vel
		else moving_anims.MAX_SPEED_RUNNING
	)
	
	var anim_speed : float = 1
	
	var main_value := 8.0
	anim_speed = max(-(main_value * delta - abs_vel * (delta * 0.5)), 1.5)
	
	animator.set("parameters/ground_moving_state/current", current_moving_anim)
	animator.set("parameters/ground_moving_time_scale/scale", anim_speed)
