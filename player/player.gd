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
	SKIDDING
}

const SNAP_MARGIN := 15.0
const FALL := 60.0
const IDLE_LIMIT := 2.0

var snap_height : float
var ground_vel : float
var ground_angle : float
var is_grounded : bool = false
var vel : Vector2
var input_axis : Vector2 = Vector2.ZERO

# facing can only be 1(right) or -1(left)
var facing : int setget set_facing, get_facing

onready var character: Character = $Character
onready var character_pos: Position2D = $CharacterPos
onready var main_shape: CollisionShape2D = $MainShape
onready var bottom_pos: Position2D = $Character/BottomPos
onready var state_machine: StateMachine = $StateMachine
onready var control_unlock_timer: Timer = $ControlUnlockTimer

# gs is for ground_sensor
onready var gs_left:RayCast2D = $LeftGroundSensor
onready var gs_middle:RayCast2D = $MiddleGroundSensor
onready var gs_right:RayCast2D = $RightGroundSensor

# slope sensors
onready var ss_left:RayCast2D = $LeftSlopeSensor
onready var ss_right:RayCast2D = $RightSlopeSensor


func _ready():
	state_machine._host_ready(self)
	_setup_top_levels()
	set_physics_process(true)
	set_process(true)


func _physics_process(delta):
	if is_on_floor():
		is_grounded = true
	var g_sensor = _get_ground_sensor()
	if g_sensor != null:
		handle_ground(delta)
	else:
		is_grounded = false
	#print(rad2deg(ground_angle))
	apply_motion()
	state_machine._fsm_physics_update(delta)


func _process(delta):
	state_machine._fsm_update(delta)
	var target_pos = character_pos.global_position - global_position
	var is_stepped = stepify(abs((ground_angle/(PI*0.5)) - float(get_ground_mode())), 0.01)
	var sprite_offset = (
		Vector2(sin(ground_angle), cos(ground_angle))
		if is_stepped != 0
		else Vector2.ZERO
	)
	character.global_position = global_position + target_pos + sprite_offset

func p_input(event : InputEvent, actions:Dictionary) -> void:
	var current_axis := Input.get_vector(
		actions.left,
		actions.right,
		actions.up,
		actions.down
	).round()
	if is_control_locked():
		current_axis.x = 0
	input_axis = current_axis


func handle_ground(delta:float):
	var ground_mode = get_ground_mode()
	if abs(ground_vel) < FALL and ground_mode != 0 and !is_control_locked():
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


func is_control_locked():
	return control_unlock_timer.time_left > 0 


func lock_control(time:float=1.0) -> void:
	control_unlock_timer.start(time)
	#ground_vel = 0


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
		deg2rad(76),
		true
	)
	return vel


func handle_friction(factor: float = 1.0) -> void:
	var delta : float = get_physics_process_delta_time()
	var frc := physics_values().frc
	ground_vel = move_toward(ground_vel, 0.0, frc * delta * factor)


func handle_acceleration() -> void:
	var delta : float = get_physics_process_delta_time()
	var values = physics_values()
	var acc_or_dec = (
		values.acc  if Utils.is_same_sign(input_axis.x, ground_vel)
		else values.dec
	)
	ground_vel = move_toward(ground_vel, values.top_spd * input_axis.x, acc_or_dec * delta)


func handle_slope(slp:float) -> void:
	var delta : float = get_physics_process_delta_time()
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
	snap_height = 0


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
	

func get_ground_mode() -> int:
	var mode = int(stepify(ground_angle, Utils.HPI)/(Utils.HPI)) % 4
	return mode if mode != -2 else -mode

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
#	if left_point >= right_point:
#		print("left")
#	else:
#		print("right")
	return (
		gs_left if left_point >= right_point
		else gs_right
	)

func _get_slope_sensor() -> RayCast2D:
	if !ss_left.is_colliding() and !ss_right.is_colliding():
		return null
	elif ss_left.is_colliding() and !ss_right.is_colliding() and ground_vel < 0:
		return ss_left
	elif ss_right.is_colliding() and !ss_left.is_colliding() and ground_vel > 0:
		return ss_right
	
	var l_angle = ss_left.get_collision_normal().angle()
	var r_angle = ss_right.get_collision_normal().angle()
	
	if is_equal_approx(l_angle, 0) and is_equal_approx(r_angle, -PI):
		return null
	elif is_equal_approx(l_angle, 0) and !is_equal_approx(r_angle, -PI):
		return ss_left
	elif is_equal_approx(r_angle, 0) and !is_equal_approx(l_angle, -PI):
		return ss_right
	return null


func _setup_top_levels() -> void:
	character.set_as_toplevel(true)
