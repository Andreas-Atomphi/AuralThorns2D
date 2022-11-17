class_name Utils
extends Object

const HPI = PI*0.5

enum Vec2Factor {
	UP, RIGHT, DOWN, LEFT
}

static func angle2Vec(radians : float, factor:int=0) -> Vector2:
	var c_radians = cos(radians)
	var s_radians = sin(radians)
	match factor:
		Vec2Factor.UP: return Vector2(s_radians, -c_radians)
		Vec2Factor.RIGHT: return Vector2(c_radians, s_radians)
		Vec2Factor.DOWN: return Vector2(s_radians, c_radians)
		Vec2Factor.LEFT: return Vector2(-c_radians, s_radians)
	return Vector2.ZERO


# all actions must follow the following pattern: "ig_inputnameexample" (ig is for in-game)
# will be converted to ig_inputnameexample_pid
static func convert_action(action: String, p_id: int) -> String:
	return "%s_%d" % [action, p_id]


# get all converted ig actions
static func get_ig_actions(p_index:int) -> IGActions:
	return IGActions.new(p_index)

# Math

# check if left and right sign is the same
static func is_same_sign(left:float, right:float) -> bool:
	return sign(left) == sign(right)

static func is_sign_opposite(left:float, right:float) -> bool:
	if left == 0 and right == 0:
		return false
	return sign(left) == -sign(right)

static func move_toward_angle(p_from: float, p_to: float, p_delta:float) -> float:
	var to_return : float = 0.0
	var from := p_from
	var to := p_to
	var delta := p_delta
	
	if to < from + PI:
		return move_toward(p_from, p_to, p_delta)
	
	return move_toward(p_from, p_to, -p_delta)


static func to_urad(p_rad:float) -> float:
	var rad := p_rad
	while rad < 0:
		rad += TAU
	while rad >= 360:
		rad -= TAU
	return rad


static func collider_normal_to_angle(p_ray:RayCast2D) -> float:
	if !p_ray.is_colliding():
		return 0.0
	return p_ray.get_collision_normal().angle_to(Vector2.UP)
