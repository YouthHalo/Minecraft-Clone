extends Node3D

var stone = preload("res://scenes/blocks/stone.tscn")
var dirt = preload("res://scenes/blocks/dirt.tscn")
# Called when the node enters the scene tree for the first time.

var plane_size = 100
var block_size = 1.0

func _ready():
	generate_planes()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func generate_planes() -> void:
	for x in plane_size:
		for z in plane_size:
			# Generate stone blocks at y=0
			var stone_instance: Node3D = stone.instantiate()
			stone_instance.transform.origin = Vector3(x * block_size, 0, z * block_size)
			add_child(stone_instance)
			
			# Generate dirt blocks at y=1
			var dirt_instance: Node3D = dirt.instantiate()
			dirt_instance.transform.origin = Vector3(x * block_size, block_size, z * block_size)
			add_child(dirt_instance)
