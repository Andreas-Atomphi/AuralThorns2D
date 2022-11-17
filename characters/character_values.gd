extends Resource
class_name CharacterPhysicsValues

# Acceleration
export(float) var acc : float = 281.25

# Deceleration
export(float) var dec : float = 1800.0

# Friction
export(float) var frc : float = 281.25

export(float) var air_acc : float = 430.0

# Top Speed
export(float) var top_spd : float = 600.0

# Jump force
export(float) var jmp : float = 340.0

# Gravity
export(float) var grv : float = 757.5

# normal Slope Factor
export(float) var slp : float = 500.0

# Slope Factor when is rolling up
export(float) var slp_roll_up : float = 210.75

# Slope Factor whe is rolling down
export(float) var slp_roll_down : float = 31.25
