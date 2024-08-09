extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$"FPS Counter".text = "FPS: " + str(Engine.get_frames_per_second())
	$"Frame Time".text = "Frame Time: " + str(round(delta*100000)/100) + "ms"
