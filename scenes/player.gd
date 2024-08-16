extends CharacterBody3D

const SPEED = 6.0
const JUMP_VELOCITY = 6.5
const MAX_STEP_HEIGHT = 0.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouseSens = 0.005
var speedMulti = 1
var health = 100
var rotX = 0
var rotY = 0
var blockID = 2
var canPlace = true
var canBreak = true
var inInventory = false

var snappedToStairsLastFrame:= false
var lastFrameWasOnFloor = -INF

@onready var head = $Body/Head
@onready var camera = $Body/Head/Camera3D
@onready var raycast = $Body/Head/Camera3D/RayCast3D
@onready var blockHighlight = $"../Block Select"

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Body/Head/Camera3D/MeshInstance3D/GridMap.set_cell_item(Vector3(0,0,0), blockID)
	blockHand()
	RenderingServer.set_debug_generate_wireframes(true)


func is_surface_too_steep(normal: Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle


func snap_down_to_stairs_check() -> void:
	var didSnap:= false
	var floorBelow : bool = $StairBelowRaycast3D.is_colliding() and not is_surface_too_steep($StairAheadRayCast3D.get_collision_normal())
	var wasOnFloorLastFrame = Engine.get_physics_frames() - lastFrameWasOnFloor == 1
	if not is_on_floor() and velocity.y <=0 and (wasOnFloorLastFrame or snappedToStairsLastFrame) and floorBelow:
		var bodyTestResult = PhysicsTestMotionResult3D.new()
		if run_body_test_motion(self.global_transform, Vector3(0, -MAX_STEP_HEIGHT, 0), bodyTestResult):
			var translateY = bodyTestResult.get_travel().y
			self.position.y += translateY
			apply_floor_snap()
			didSnap = true
	snappedToStairsLastFrame = didSnap


func snap_up_stairs_check(delta) -> bool:
	if not is_on_floor() and not snappedToStairsLastFrame:
		return false
	var expectedMoveMotion = self.velocity * Vector3(1, 0, 1) * delta
	var stepPosWithClearance = self.global_transform.translated(expectedMoveMotion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	
	var downCheckResult = PhysicsTestMotionResult3D.new()
	if (run_body_test_motion(stepPosWithClearance, Vector3(0, -MAX_STEP_HEIGHT * 2, 0), downCheckResult) and (downCheckResult.get_collider().is_class("GridMap"))):
		var stepHeight = ((stepPosWithClearance.origin + downCheckResult.get_travel()) - self.global_position).y
		if stepHeight > MAX_STEP_HEIGHT or stepHeight <= 0.01 or (downCheckResult.get_collision_point() - self.global_position).y > MAX_STEP_HEIGHT:
			return false
		$StairAheadRayCast3D.global_position = downCheckResult.get_collision_point() + Vector3(0, MAX_STEP_HEIGHT, 0) + expectedMoveMotion.normalized() * 0.1
		$StairAheadRayCast3D.force_raycast_update()
		if $StairAheadRayCast3D.is_colliding() and not is_surface_too_steep($StairAheadRayCast3D.get_collision_normal()):
			self.global_position = stepPosWithClearance.origin + downCheckResult.get_travel()
			apply_floor_snap()
			snappedToStairsLastFrame = true
			return true
	return false


func stairs():
	if is_on_floor():
		lastFrameWasOnFloor = Engine.get_physics_frames()


func run_body_test_motion(from: Transform3D, motion: Vector3, result = null) -> bool:
	if not result:
		result = PhysicsTestMotionResult3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(self.get_rid(), params, result)


func movement(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Handle jump.
		if Input.is_action_pressed("jump") and (is_on_floor() or snappedToStairsLastFrame):
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("left", "right", "forward", "backward")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if inInventory:
			direction = 0
		if direction:
			velocity.x = direction.x * SPEED * speedMulti
			velocity.z = direction.z * SPEED * speedMulti
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		
		if Input.is_action_just_pressed("crouch"):
			head.position.y = 0.495
			speedMulti = 0.3
		if Input.is_action_just_released("crouch"):
			head.position.y = 0.62
			speedMulti = 1
		
		if Input.is_action_just_pressed("scrollUp"):
			blockID += 1
			blockHand()
		if Input.is_action_just_pressed("scrollDown"):
			blockID -= 1
			blockHand()


func _input(event):
	if event is InputEventKey and Input.is_key_pressed(KEY_P):
		var vp = get_viewport()
		vp.debug_draw = (vp.debug_draw + 1 ) % 5

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# modify accumulated mouse rotation
		rotX += -(event.relative.x * mouseSens)
		rotY += -(event.relative.y * mouseSens)
		
		if rotY > deg_to_rad(90):
			rotY = deg_to_rad(90)
		if rotY < deg_to_rad(-90):
			rotY = deg_to_rad(-90)
		head.transform.basis = Basis() # reset rotation
		transform.basis = Basis()
		rotate_object_local(Vector3(0, 1, 0), rotX) # rotate player in Y
		head.rotation.x = clamp(rotY, deg_to_rad(-90), deg_to_rad(90))

	if Input.is_action_just_pressed("leftClick"):
		if not inInventory:
			breakBlock()
		
	if Input.is_action_just_pressed("rightClick"):
		if not inInventory:
			buildBlock()
	
	if Input.is_action_just_pressed("inventory"):
		if not inInventory:
			velocity.x = 0
			velocity.z = 0
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
	stairs()
	movement(delta)
	if not snap_up_stairs_check(delta):
		move_and_slide()
		snap_down_to_stairs_check()
	blockSelector()
