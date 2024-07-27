extends RigidBody3D

enum {
	NORMAL,
	GRABBED
}

@export var grab_velocity_speed : float = 5.0
@export var grab_angular_speed : float = 5.0

var state = NORMAL
var target_node : Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("grabable")
	pass # Replace with function body.

func toggle_grab(target:Node3D):
	if state == NORMAL:
		grabbed(target)
	else:
		released()
	
func grabbed(target : Node3D):
	target_node = target
	state = GRABBED
	gravity_scale = 0.0
	
func released():
	gravity_scale = 1.0
	state = NORMAL

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if state == NORMAL:
		return
	
	#IF GRABBED and target_node exists, DO FOLLOWING LOGIC
	linear_velocity = (target_node.global_position - global_position) * grab_velocity_speed
	angular_velocity = calc_angular_velocity(global_basis, target_node.global_basis) * grab_angular_speed

func calc_angular_velocity(from_basis: Basis, to_basis: Basis) -> Vector3:
	var q1 = from_basis.get_rotation_quaternion()
	var q2 = to_basis.get_rotation_quaternion()

	# Quaternion that transforms q1 into q2
	var qt = q2 * q1.inverse()

	# Angle from quaternion
	var angle = 2 * acos(qt.w)

	# There are two distinct quaternions for any orientation.
	# Ensure we use the representation with the smallest angle.
	if angle > PI:
		qt = -qt
		angle = TAU - angle

	# Prevent divide by zero
	if angle < 0.0001:
		return Vector3.ZERO

	# Axis from quaternion
	var axis = Vector3(qt.x, qt.y, qt.z) / sqrt(1-qt.w*qt.w)

	return axis * angle
