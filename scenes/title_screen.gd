extends Control

@onready var splash = $SplashText

var grow = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if splash.scale < Vector2(1.2, 1.2) and grow:
		if splash.scale == Vector2(1.2, 1.2):
			print("GROWSTOP")
			grow = false

		splash.scale += Vector2(0.01, 0.01)
		print(splash.scale)

	if splash.scale > Vector2(0.75, 0.75) and not grow:
		splash.scale -= Vector2(0.05, 0.05)
		if splash.scale == Vector2(0.8, 0.8):
			grow = true
			print("GROWSTART")

func _on_quit_pressed():
	get_tree().quit()

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
