extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
func _input(event):
	if event is InputEventKey and Input.is_key_pressed(KEY_T):
		$OccluderInstance3D.position.x += 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
