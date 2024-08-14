extends Control

@onready var splash = $SplashText

var grow = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if splash.scale < Vector2(1.05, 1.05) and grow:
		splash.scale += Vector2(0.005, 0.005)
		
	if splash.scale == Vector2(1.05, 1.05) and grow:
		grow = false

	if splash.scale > Vector2(0.95, 0.95) and not grow:
		splash.scale -= Vector2(0.005, 0.005)

	if splash.scale < Vector2(0.95, 0.95) and not grow:
		await get_tree().create_timer(0.05).timeout
		grow = true


func _on_quit_pressed():
	get_tree().quit()

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
