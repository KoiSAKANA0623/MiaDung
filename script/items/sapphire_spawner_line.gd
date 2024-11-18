extends Node3D


@export var length = 1
@export var type = 0

@onready var lineSpawner = $LineSpawn
@onready var circleSpawner = $CircleSpawn

@onready var sapp = preload("res://scene/items/sapphire.tscn")

var sappArray


# Called when the node enters the scene tree for the first time.
func _ready():
	if type == 0:
		sappArray = lineSpawner.get_children()
		sappArray.resize(clamp(length, 1, 7))
		for i in sappArray:
			var sappInst = sapp.instantiate()
			i.add_child(sappInst)
		return
	if type == 1:
		sappArray = circleSpawner.get_children()
		for i in sappArray:
			var sappInst = sapp.instantiate()
			i.add_child(sappInst)
		return
	else:
		return
