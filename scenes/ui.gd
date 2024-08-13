extends Control

@onready var player = $"../../../.."
# Called when the node enters the scene tree for the first time.

var paused = false

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$"FPS Counter".text = "FPS: " + str(Engine.get_frames_per_second())
	$"Frame Time".text = "Frame Time: " + str(round(delta*100000)/100) + "ms"
	$Coordinates.text = "(" + str(round(player.position.x * 100) / 100) + ", " + str(round(player.position.y * 100) / 100 + 0.06) + ", " + str(round(player.position.z * 100) / 100) + ")"
	
	if Input.is_action_just_pressed("pause"):
		if not paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().paused = true
			paused = true
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_tree().paused = false
			paused = false
	if paused:
		$"Pause Menu".show()
	else:
		$"Pause Menu".hide()
	
