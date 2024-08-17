extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var mouseSens = 0.005
var rotX = 0
var rotY = 0


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	RenderingServer.set_debug_generate_wireframes(true)


func _input(event):
	if event is InputEventKey and Input.is_key_pressed(KEY_P):
		var vp = get_viewport()
		vp.debug_draw = (vp.debug_draw + 1 ) % 5
	if event is InputEventKey and Input.is_key_pressed(KEY_T):
		print("does this work")
		$"../OccluderInstance3D".position.x += 1
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# modify accumulated mouse rotation
		rotX += -(event.relative.x * mouseSens)
		rotY += -(event.relative.y * mouseSens)

		if rotY > deg_to_rad(90):
			rotY = deg_to_rad(90)
		if rotY < deg_to_rad(-90):
			rotY = deg_to_rad(-90)
		transform.basis = Basis() # reset rotation
		transform.basis = Basis()
		rotate_object_local(Vector3(0, 1, 0), rotX) # rotate player in Y
		rotation.x = clamp(rotY, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:

	# Handle jump.
	if Input.is_action_pressed("jump"):
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_pressed("crouch"):
		velocity.y = -JUMP_VELOCITY
	else:
		velocity.y = 0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
