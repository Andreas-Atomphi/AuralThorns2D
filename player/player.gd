extends KinematicBody2D
class_name Player

enum MainStates {
	GROUND,
	AIR,
	CHAR_SPECIFIC
}

enum GroundStates {
	STOPPED,
	MOVING
}

enum StoppedAnims {
	IDLE,
	LOOKING_UP,
	CROUCHING,
	SPIN_DASH,
	PUSHING
}

enum MovingAnims {
	WALKING,
	JOGGING,
	RUNNING,
	MAX_SPEED_RUNNING,
	ROLLING,
	SKIDDING
}

enum AirStates {
	AIRBONE,
	PUSHED_BY_SPRING,
	THROWED
}

# Player main states
const IDLE = "Idle"
const MOVING = "Moving"
const ROLLING = "Rolling"
const ON_AIR = "OnAir"

const SNAP_MARGIN := 2.0
const FALL := 40.0
const IDLE_LIMIT := 3.0
const MOVING_LIMIT := 68.0
const SLOPE_TOLERANCE := deg2rad(76)

var snap_height : float
var ground_vel : float
var ground_angle : float
var is_grounded : bool = false
var vel : Vector2
var input_axis : Vector2 = Vector2.ZERO
var ig_actions :IGActions
var airbone : bool = false
# facing can only be 1(right) or -1(left)
var facing : int setget set_facing, get_facing

onready var character: Character = $Character
onready var character_pos: Position2D = $CharacterPos
onready var main_shape: CollisionShape2D = $MainShape
onready var bottom_pos: Position2D = $Character/BottomPos
onready var state_machine := $StateMachine
onready var control_unlock_timer: Timer = $ControlUnlockTimer
# gs is for ground_sensor
onready var gs_left:RayCast2D = $LeftGroundSensor
onready var gs_middle:RayCast2D = $MiddleGroundSensor
onready var gs_right:RayCast2D = $RightGroundSensor
# slope sensors
onready var ss_left:RayCast2D = $LeftSlopeSensor
onready var ss_right:RayCast2D = $RightSlopeSensor


func _ready() -> void:
	state_machine._host_ready(self)
	_setup_top_levels()
	set_physics_process(true)
	set_process(true)


func _physics_process(delta) -> void:
	if is_on_floor():
		is_grounded = true
	
	var g_sensor = _get_ground_sensor()
	if g_sensor != null:
		handle_ground(delta)
	else:
		is_grounded = false
	
	apply_motion()
	state_machine._fsm_physics_update(delta)


func _process(delta) -> void:
	state_machine._fsm_update(delta)
	var target_pos = character_pos.global_position - global_position
	var is_stepped = stepify(abs((ground_angle/(PI*0.5)) - float(get_ground_mode())), 0.01)
	var sprite_offset = (
		Vector2(sin(ground_angle), cos(ground_angle)) if is_stepped != 0
		else Vector2.ZERO
	)
	character.global_position = global_position + target_pos + sprite_offset

func p_input(event : InputEvent) -> void:
	var current_axis := Input.get_vector(
		ig_actions.left,
		ig_actions.right,
		ig_actions.up,
		ig_actions.down
	).round()
	if is_control_locked():
		current_axis.x = 0
	input_axis = current_axis
	
	state_machine._fsm_input(event, ig_actions)


func is_jump_btn_just_pressed() -> bool:
	return (
		Input.is_action_just_pressed(ig_actions.j1)
		or Input.is_action_just_pressed(ig_actions.j2)
		or Input.is_action_just_pressed(ig_actions.j3)
	)


func is_jump_btn_just_released() -> bool:
	return (
		Input.is_action_just_released(ig_actions.j1)
		or Input.is_action_just_released(ig_actions.j2)
		or Input.is_action_just_released(ig_actions.j3)
	)


func is_jump_btn_pressed() -> bool:
	return (
		Input.is_action_pressed(ig_actions.j1)
		or Input.is_action_pressed(ig_actions.j2)
		or Input.is_action_pressed(ig_actions.j3)
	)


func handle_ground(delta:float) -> void:
	var ground_mode = get_ground_mode()
	if abs(ground_vel) < FALL and ground_mode != 0 and not is_control_locked():
		lock_control()
		if ground_mode == 2:
			is_grounded = false
			return
		var sub = delta * FALL
		if ground_angle < PI:
			sub *= -1
		ground_vel += sub


func physics_values() -> CharacterPhysicsValues:
	return character.values as CharacterPhysicsValues


func animator() -> AnimationTree:
	return character.animator as AnimationTree


func convert_ground_vel(angle=ground_angle) -> Vector2:
	return Vector2(cos(angle), -sin(angle)) * ground_vel


func handle_ground_vel() -> void:
	vel = convert_ground_vel()


func is_control_locked() -> bool:
	return control_unlock_timer.time_left > 0 


func is_anim_rolling() -> bool:
	var animator := animator()
	return (
		(
			animator.get("parameters/main_transition/current") == MainStates.GROUND
			and animator.get("parameters/ground_transition/current") == GroundStates.MOVING
			and animator.get("parameters/ground_moving_state/current") == MovingAnims.ROLLING
		)
		or (
			animator.get("parameters/main_transition/current") == MainStates.AIR
			and animator.get("parameters/air_state/current") == AirStates.AIRBONE
		)
		or character.is_anim_rolling()
	)

func lock_control(time:float=1.0) -> void:
	control_unlock_timer.start(time)
	input_axis.x = 0


func unlock_control() -> void:
	control_unlock_timer.stop()


func apply_motion() -> Vector2:
	return apply_motion_to(vel)


func apply_motion_to(sp : Vector2) -> Vector2:
	var up_dir = Utils.angle2Vec(ground_angle, Utils.Vec2Factor.UP)
	var bottom_snap = -up_dir * snap_height
	vel = move_and_slide_with_snap(
		sp,
		bottom_snap,
		up_dir,
		true,
		4,
		SLOPE_TOLERANCE,
		true
	)
	return vel


func handle_friction(factor: float = 1.0) -> void:
	var delta : float = get_physics_process_delta_time()
	var frc := physics_values().frc
	ground_vel = move_toward(ground_vel, 0.0, frc * delta * factor)

# Handle both acceleration and deceleration
func handle_acc_n_dec() -> void:
	var delta : float = get_physics_process_delta_time()
	var values = physics_values()
	var acc_or_dec = (
		values.acc if Utils.is_same_sign(input_axis.x, ground_vel)
		else values.dec
	)
	ground_vel = move_toward(
		ground_vel,
		values.top_spd * input_axis.x,
		acc_or_dec * delta
	)

func handle_slope(slp:float) -> void:
	var delta : float = get_physics_process_delta_time()
	#print((slp * sin(ground_angle)) * delta)
	ground_vel -= (slp * sin(ground_angle)) * delta


func set_facing(p_value:int) -> void:
	var value = p_value
	if value == 0:
		value = facing if facing != 0 else 1
	facing = int(sign(value))
	character.scale.x = facing as float


func get_facing() -> int:
	return facing


func reset_snap() -> void:
	snap_height = SNAP_MARGIN


func erase_snap() -> void:
	snap_height = 1.0


func snap_ground() -> void:
	vel += Vector2(sin(ground_angle), cos(ground_angle)) * 150
	ground_angle = get_ground_normal().angle_to(Vector2.UP)
	rotation_degrees = -stepify(rad2deg(ground_angle), 90)


func get_ground_normal() -> Vector2:
	# Check for slopes
	var slope_s := _get_slope_sensor()
	if slope_s != null:
		return slope_s.get_collision_normal()
	
	# Check for ground
	var ground_s := _get_ground_sensor()
	if ground_s != null:
		return ground_s.get_collision_normal()
	
	return Vector2.UP


func reacquire_on_floor() -> void:
	var angle_vel := Vector2(
		cos(ground_angle),
		-sin(ground_angle)
	) * vel
	var converted_vel = angle_vel.x + angle_vel.y
	ground_vel = converted_vel


func rotate_sprite_to_ground(target_angle:float) -> void:
	var delta = get_physics_process_delta_time()
	var min_to_rotate := deg2rad(22.5)
	var factor = delta * TAU
	character.rotation = (
		move_toward(character.rotation, 0.0, factor)
		if abs(ground_angle) < min_to_rotate
		else lerp_angle(character.rotation, target_angle, factor * 2)
	)


func get_ground_mode() -> int:
	var mode = int(stepify(ground_angle, Utils.HPI)/(Utils.HPI)) % 4
	return mode if mode != -2 else -mode


func jump() -> String:
	vel -= Vector2(sin(ground_angle), cos(ground_angle)) * physics_values().jmp 
	is_grounded = false
	erase_snap()
	apply_motion()
	ground_angle = 0
	airbone = true
	return ON_AIR

func is_ray_colliding_wall(p_ray:RayCast2D) -> bool:
	if not p_ray.is_colliding():
		return false
	return _is_wall(
		p_ray.get_collision_normal().angle()
	)

func is_colliding_wall_left() -> bool:
	return is_ray_colliding_wall(ss_left) and ss_left.get_collision_point().x >= ss_left.global_position.x - 2


func is_colliding_wall_right() -> bool:
	return is_ray_colliding_wall(ss_right) and ss_right.get_collision_point().x <= ss_right.global_position.x + 2


func is_pushing_wall() -> bool:
	return (
		(is_colliding_wall_left() and ground_vel + input_axis.x < 0)
		or (is_colliding_wall_right() and ground_vel + input_axis.x > 0)
	)


func can_fall() -> bool:
	return not gs_left.is_colliding() and not gs_right.is_colliding()


func _get_ground_sensor() -> RayCast2D:
	if !gs_left.is_colliding() and !gs_right.is_colliding():
		return null
	elif gs_left.is_colliding() and !gs_right.is_colliding():
		return gs_left
	elif gs_right.is_colliding() and !gs_left.is_colliding():
		return gs_right
	
	var left_coll_point = gs_left.get_collision_point()
	var right_coll_point = gs_right.get_collision_point()
	
	var left_point
	var right_point
	match get_ground_mode():
		0:
			left_point = -left_coll_point.y
			right_point = -right_coll_point.y
		1:
			left_point = -left_coll_point.x
			right_point = -right_coll_point.x
		2:
			left_point = left_coll_point.y
			right_point = right_coll_point.y
		-1:
			left_point = left_coll_point.x
			right_point = right_coll_point.x
	return (
		gs_left if left_point >= right_point
		else gs_right
	)


func _get_slope_sensor() -> RayCast2D:
	if not ss_left.is_colliding() and not ss_right.is_colliding():
		return null
	
	var is_left_coll_wall = is_ray_colliding_wall(ss_left)
	if ss_left.is_colliding() and not ss_right.is_colliding():
		return null if is_left_coll_wall else ss_left
	
	var is_right_coll_wall = is_ray_colliding_wall(ss_right)
	if ss_right.is_colliding() and not ss_left.is_colliding():
		return null if is_right_coll_wall else ss_right
	
	if is_left_coll_wall and is_right_coll_wall:
		return null
	elif is_left_coll_wall and not is_right_coll_wall:
		return ss_left
	elif is_right_coll_wall and not is_left_coll_wall:
		return ss_right
	
	return null

func _is_wall(angle) -> bool:
	#prints(abs(rad2deg(angle)), rad2deg(rotation), rad2deg(SLOPE_TOLERANCE+rotation))
	return abs(angle) >= SLOPE_TOLERANCE+rotation

func _setup_top_levels() -> void:
	character.set_as_toplevel(true)
