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
var inInventory = false

@onready var head = $Body/Head
@onready var camera = $Body/Head/Camera3D
@onready var raycast = $Body/Head/Camera3D/RayCast3D
@onready var blockHighlight = $"../Block Select"
@onready var stairStep = $"StairStep"


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Body/Head/Camera3D/MeshInstance3D/GridMap.set_cell_item(Vector3(0,0,0), blockID)
	blockHand()


func is_surface_too_steep(normal: Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle


func _run_body_test_motion(from: Transform3D, motion: Vector3, result = null) -> bool:
	if not result:
		result = PhysicsTestMotionResult3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion

func movement(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
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
			head.position.y = 0.495
			speedmulti = 0.3
		if Input.is_action_just_released("crouch"):
			head.position.y = 0.62
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
		head.transform.basis = Basis() # reset rotation
		transform.basis = Basis()
		rotate_object_local(Vector3(0, 1, 0), rot_x) # rotate player in Y
		head.rotation.x = clamp(rot_y, deg_to_rad(-90), deg_to_rad(90))

	if Input.is_action_just_pressed("leftClick"):
		if not inInventory:
			breakBlock()
		
	if Input.is_action_just_pressed("rightClick"):
		if not inInventory:
			buildBlock()
	
	if Input.is_action_just_pressed("inventory"):
		if not inInventory:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			inInventory = true
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			inInventory = false


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
		if collider is GridMap and canPlace:
			var collisionPoint = raycast.get_collision_point()
			if collider.get_cell_item(collider.local_to_map(collisionPoint)) != -1:
				collider.set_cell_item(collider.local_to_map(collisionPoint + raycast.get_collision_normal()), blockID)	
			else:
				collider.set_cell_item(collider.local_to_map(collisionPoint), blockID)
			if canPlace:
				canPlace = false
				await get_tree().create_timer(1/60).timeout
				canPlace = true

func blockHand():
	$Body/Head/Camera3D/MeshInstance3D/GridMap.set_cell_item(Vector3(0,0,0), blockID)

func blockSelector():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider is GridMap:
			blockHighlight.show()
			var collisionPoint = raycast.get_collision_point()
			if collider.get_cell_item(collider.local_to_map(collisionPoint)) == -1:
				blockHighlight.position = collider.local_to_map(collisionPoint + Vector3(-0.01 , -0.01, -0.01))
				blockHighlight.position += Vector3(0.5, 0.5, 0.5)
				
			else:
				blockHighlight.position = collider.local_to_map(collisionPoint)
				blockHighlight.position += Vector3(0.5, 0.5, 0.5)
	else :
		blockHighlight.hide()

func _physics_process(delta):
	movement(delta)
	move_and_slide()
	blockSelector()
