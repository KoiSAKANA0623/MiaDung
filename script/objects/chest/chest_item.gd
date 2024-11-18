extends Node3D

var material = load("res://texture/chest_item_texture.tres")

@onready var anim = $AnimationPlayer

var type = null


func _ready():
	anim.play("Main")


func _process(delta):
	if type == "Sapphire":
		material.uv1_offset = Vector3(0.5, 0, 0)
	elif type == "Eggs":
		material.uv1_offset = Vector3(0, 0, 0)
	elif type == "Spaghetti":
		material.uv1_offset = Vector3(0.25, 0, 0)
	elif type == "Tomato":
		material.uv1_offset = Vector3(0, 0.25, 0)
	elif type == "Basil":
		material.uv1_offset = Vector3(0.25, 0.25, 0)
	elif type == "Milk":
		material.uv1_offset = Vector3(0.5, 0.25, 0)
	else:
		material.uv1_offset = Vector3(0, 0.75, 0)


func _disappear():
	queue_free()
