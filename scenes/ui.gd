extends Control

@onready var player = $"../../../.."
@onready var pauseMenu = $"Pause Menu"
@onready var inventory = $Inventory
# Called when the node enters the scene tree for the first time.

var paused = false
var inInventory = false

func _ready():
	pauseMenu.hide()
	inventory.hide()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$"FPS Counter".text = "FPS: " + str(Engine.get_frames_per_second())
	$"Frame Time".text = "Frame Time: " + str(round(delta*100000)/100) + "ms"
	$Coordinates.text = "(" + str(round(player.position.x * 100) / 100) + ", " + str(round(player.position.y * 100) / 100 + 0.06) + ", " + str(round(player.position.z * 100) / 100) + ")"
	
	if Input.is_action_just_pressed("pause"):
		if not paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			pauseMenu.show()
			get_tree().paused = true
			paused = true
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			pauseMenu.hide()
			get_tree().paused = false
			paused = false

	if Input.is_action_just_pressed("inventory"):
		if not inInventory:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			inventory.show()
			inInventory = true
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			inventory.hide()
			inInventory = false
	

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")


func _on_resume_pressed():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pauseMenu.hide()
	get_tree().paused = false
	paused = false
