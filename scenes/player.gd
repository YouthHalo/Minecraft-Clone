extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sens = 0.005
var rot_x = 0
var rot_y = 0
var blockID = 0
@onready var raycast = $Camera3D/RayCast3D
@onready var camera = $Camera3D


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func movement(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)


func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# modify accumulated mouse rotation
		rot_x += -(event.relative.x * 0.01)
		rot_y += -(event.relative.y * 0.01)
		
		camera.transform.basis = Basis() # reset rotation
		transform.basis = Basis()
		rotate_object_local(Vector3(0, 1, 0), rot_x) # rotate player in Y
		
		camera.rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X for camera


	if Input.is_action_just_pressed("leftClick"):
		
		breakBlock()
		
		
	if Input.is_action_just_pressed("rightClick"):
		buildBlock()

func breakBlock():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider is GridMap:
			var collisionPoint = raycast.get_collision_point()
			collider.set_cell_item(collider.local_to_map(collisionPoint), -1)

func buildBlock():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider is GridMap:
			var collisionPoint = raycast.get_collision_point()
			collider.set_cell_item(collider.local_to_map(collisionPoint), blockID)
			print(collider.get_cell_item_orientation(collider.local_to_map(collisionPoint)))
			

func _physics_process(delta):
	movement(delta)
	move_and_slide()
