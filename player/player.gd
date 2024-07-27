extends CharacterBody3D

@export var MOUSE_SENSITIVITY :float = 0.005
@export var rot_x_min : float = -70.0
@export var rot_x_max : float = 70.0

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var axis_y = $axis_y
@onready var axis_x = $axis_y/axis_x
@onready var holder = $axis_y/axis_x/holder
@onready var ray_activator = $axis_y/axis_x/ray_activator


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	rot_x_min = deg_to_rad(rot_x_min)
	rot_x_max = deg_to_rad(rot_x_max)
	
	
func _input(event):
	if event is InputEventMouseMotion:
		axis_y.rotation.y -= event.relative.x * MOUSE_SENSITIVITY
		axis_x.rotation.x -= event.relative.y * MOUSE_SENSITIVITY
		axis_x.rotation.x = clamp(axis_x.rotation.x, rot_x_min, rot_x_max)
		
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (axis_y.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	#GRAB LOGIC HERE
	if Input.is_action_just_pressed("activate"):
		if ray_activator.is_colliding():
			var obj = ray_activator.get_collider()
			if obj.is_in_group("grabable"):
				obj.toggle_grab(holder)
	
