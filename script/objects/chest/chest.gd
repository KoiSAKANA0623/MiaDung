extends Node3D

var chest_item = load("res://scene/chest_item.tscn")

var chestOpen = load("res://sound/chest/chestOpen.ogg")
var chestClose = load("res://sound/Chest/chestClose.ogg")

@export var current_item: String

@onready var anim = $Chest/AnimationPlayer
@onready var collision = $StaticBody3D/CollisionShape3D
@onready var audioPlayer = $AudioStreamPlayer3D

var is_open = false


# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("Idle")


func _process(delta):
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func open_chest():
	var item = chest_item.instantiate()
	add_child(item)
	item.position.y = 1
	item.type = current_item
	anim.play("Open")
	is_open = true
	audioPlayer.stream = chestOpen
	audioPlayer.play()
	await get_tree().create_timer(2).timeout
	item._disappear()
	anim.play("Disappear")
	collision.disabled = true
	audioPlayer.stream = chestClose
	audioPlayer.play()
	await get_tree().create_timer(0.5).timeout
	queue_free()
