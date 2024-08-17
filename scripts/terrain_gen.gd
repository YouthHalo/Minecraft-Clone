extends Node3D

var stone = preload("res://scenes/blocks/stone.tscn")
var dirt = preload("res://scenes/blocks/dirt.tscn")
var ore = preload("res://scenes/blocks/diamond_ore.tscn")
@onready var camera = $TestCamera/Camera3D
# Called when the node enters the scene tree for the first time.

var plane_size = 128
var block_size = 1.0
var mouseSens = 0.005
var Y = 0


func _ready():
	generate_planes()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$RichTextLabel.text = "FPS: " + str(Engine.get_frames_per_second())


func _input(event):
	if event is InputEventKey and Input.is_key_pressed(KEY_T):
		generate_planes2()
		$OccluderInstance3D.position.x += 0.1


func generate_planes() -> void:
	for x in plane_size:
		for z in plane_size:
			var ore_instance: Node3D = ore.instantiate()
			ore_instance.transform.origin = Vector3(1 * block_size, Y, 1 * block_size)
			add_child(ore_instance)
			var stone_instance: Node3D = stone.instantiate()
			stone_instance.transform.origin = Vector3(1 * block_size, Y+1, 1 * block_size)
			add_child(stone_instance)
			# Generate dirt blocks at y=1
			var dirt_instance: Node3D = dirt.instantiate()
			dirt_instance.transform.origin = Vector3(1 * block_size, Y+2, 1 * block_size)
			add_child(dirt_instance)
	Y += 3


func generate_planes2() -> void:
	var ore_instance: Node3D = ore.instantiate()
	ore_instance.transform.origin = Vector3(1 * block_size, Y, 1 * block_size)
	add_child(ore_instance)
	var stone_instance: Node3D = stone.instantiate()
	stone_instance.transform.origin = Vector3(1 * block_size, Y+1, 1 * block_size)
	add_child(stone_instance)
	# Generate dirt blocks at y=1
	var dirt_instance: Node3D = dirt.instantiate()
	dirt_instance.transform.origin = Vector3(1 * block_size, Y+2, 1 * block_size)
	add_child(dirt_instance)
	Y += 3
