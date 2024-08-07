extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


var rot_x = 0
var rot_y = 0

func _input(event):
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	if event is InputEventMouseMotion:
		# modify accumulated mouse rotation
		rot_x += -(event.relative.x * 0.02)
		rot_y += -(event.relative.y * 0.02)
		$Camera3D.transform.basis = Basis() # reset rotation
		transform.basis = Basis()
		##$Camera3D.rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate camera in Y
		rotate_object_local(Vector3(0, 1, 0), rot_x) # Also rotate the Player
		$Camera3D.rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X
		

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		print("Falling")

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
	
	move_and_slide()
