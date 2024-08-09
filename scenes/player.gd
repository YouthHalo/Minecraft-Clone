extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 6.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sens = 0.005
var speedmulti = 1
var health = 100
var rot_x = 0
var rot_y = 0
var blockID = 2

var canPlace = true
var canBreak = true


@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var blockChecker = $"../Block Checker"


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hideBlocks()
	blockHand()

func hideBlocks():
	$"Camera3D/Blocks/0 - Dirt".hide()
	$"Camera3D/Blocks/1 - Stone".hide()
	$"Camera3D/Blocks/2 - Cobblestone".hide()
	$"Camera3D/Blocks/3 - Diamond Ore".hide()

func movement(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED * speedmulti
		velocity.z = direction.z * SPEED * speedmulti
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if Input.is_action_just_pressed("crouch"):
		camera.position.y = 0.495
		speedmulti = 0.3
	if Input.is_action_just_released("crouch"):
		camera.position.y = 0.62
		speedmulti = 1
	
	if Input.is_action_just_pressed("scrollUp"):
		blockID += 1
		blockHand()
	if Input.is_action_just_pressed("scrollDown"):
		blockID -= 1
		blockHand()


func _input(event):
	if position.y < -10:
		get_tree().quit()

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# modify accumulated mouse rotation
		rot_x += -(event.relative.x * mouse_sens)
		rot_y += -(event.relative.y * mouse_sens)
		
		if rot_y > deg_to_rad(90):
			rot_y = deg_to_rad(90)
		if rot_y < deg_to_rad(-90):
			rot_y = deg_to_rad(-90)
		camera.transform.basis = Basis() # reset rotation
		transform.basis = Basis()
		rotate_object_local(Vector3(0, 1, 0), rot_x) # rotate player in Y
		camera.rotation.x = clamp(rot_y, deg_to_rad(-90), deg_to_rad(90))

	if Input.is_action_just_pressed("leftClick"):
		breakBlock()
		
	if Input.is_action_just_pressed("rightClick"):
		buildBlock()

func breakBlock():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider is GridMap and canBreak:
			var collisionPoint = raycast.get_collision_point()
			if collider.get_cell_item(collider.local_to_map(collisionPoint)) == -1:
				collider.set_cell_item(collider.local_to_map(collisionPoint + Vector3(-0.01 , -0.01, -0.01)), -1)
			else:
				collider.set_cell_item(collider.local_to_map(collisionPoint), -1)
			canBreak = false
			await get_tree().create_timer(0.0166666666667).timeout
			canBreak = true

func buildBlock():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider is GridMap:
			var collisionPoint = raycast.get_collision_point()
			if collider.get_cell_item(collider.local_to_map(collisionPoint)) != -1:
				if canPlace:
					collider.set_cell_item(collider.local_to_map(collisionPoint + raycast.get_collision_normal()), blockID)
				return
			else:
				if canPlace:
					collider.set_cell_item(collider.local_to_map(collisionPoint), blockID)
			if canPlace:
				canPlace = false
				await get_tree().create_timer(1/60).timeout
				canPlace = true

func blockHand():
	hideBlocks()
	if blockID == 0:
		$"Camera3D/Blocks/0 - Dirt".show()
	if blockID == 1:
		$"Camera3D/Blocks/1 - Stone".show()
	if blockID == 2:
		$"Camera3D/Blocks/2 - Cobblestone".show()
	if blockID == 3:
		$"Camera3D/Blocks/3 - Diamond Ore".show()

func _physics_process(delta):
	movement(delta)
	move_and_slide()
